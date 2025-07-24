#!/usr/bin/env python3
"""
nvidia-sorted.py - Clean GPU stats table using nvidia-smi with properly sorted processes with highest usage first
"""

import subprocess
import sys
import os
import time

from typing import List, Tuple, Optional

def check_dependencies() -> bool:
    """Check if required tools are available"""
    try:
        subprocess.run(['nvidia-smi', '--version'], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("nvidia-smi not found")
        return False

    return True



def get_gpu_stats() -> dict:
    """Get GPU statistics using nvidia-smi queries"""
    queries = {
        'fan': 'fan.speed',
        'temp': 'temperature.gpu',
        'power': 'power.draw',
        'utilization': 'utilization.gpu',
        'memory_used': 'memory.used',
        'memory_total': 'memory.total',
        'name': 'name'
    }

    stats = {}
    for key, query in queries.items():
        try:
            result = subprocess.run(
                ['nvidia-smi', f'--query-gpu={query}', '--format=csv,noheader,nounits'],
                capture_output=True, text=True, check=True
            )
            stats[key] = result.stdout.strip()
        except subprocess.CalledProcessError:
            stats[key] = 'N/A'

    return stats

def get_processes() -> List[Tuple[str, str, str]]:
    """Get GPU processes sorted by memory usage"""
    try:
        # Get all processes using the GPU (graphics and compute)
        result = subprocess.run(['nvidia-smi'], capture_output=True, text=True, check=True)

        processes = []
        lines = result.stdout.split('\n')

        # Find the processes section
        in_processes = False
        for line in lines:
            if 'Processes:' in line:
                in_processes = True
                continue
            if in_processes and line.strip().startswith('|') and 'PID' not in line and 'GPU' not in line:
                # Parse process lines that look like: |    0   N/A  N/A      1234      G   process_name    123MiB |
                parts = line.strip('|').split()
                if len(parts) >= 6:
                    try:
                        pid = parts[3]
                        process_name = ' '.join(parts[5:-1])  # Process name might have spaces
                        memory_str = parts[-1]  # Last part is memory usage

                        # Extract numeric memory value for sorting
                        memory_int = int(memory_str.replace('MiB', '').strip()) if 'MiB' in memory_str else 0
                        processes.append((pid, process_name, memory_str, memory_int))
                    except (ValueError, IndexError):
                        continue
            elif in_processes and line.strip().startswith('+'):
                # End of processes section
                break

        # Sort by memory usage (descending)
        processes.sort(key=lambda x: x[3], reverse=True)
        return [(pid, process, memory) for pid, process, memory, _ in processes]

    except subprocess.CalledProcessError:
        return []

def calculate_memory_percentage(used: str, total: str) -> str:
    """Calculate memory usage percentage"""
    try:
        used_val = float(used)
        total_val = float(total)
        if total_val > 0:
            return f"{used_val * 100 / total_val:.0f}"
        return "N/A"
    except (ValueError, ZeroDivisionError):
        return "N/A"

def format_plain_text() -> str:
    """Generate formatted plain text with fixed-width columns"""
    stats = get_gpu_stats()
    processes = get_processes()

    percent_used = calculate_memory_percentage(stats['memory_used'], stats['memory_total'])

    output = []

    # GPU stats table with metrics as columns
    fan_col = f"{stats['fan']}%"
    temp_col = f"{stats['temp']}°C"
    power_col = f"{stats['power']}W"
    mem_used_col = f"{stats['memory_used']} MiB ({percent_used}%)"
    mem_total_col = f"{stats['memory_total']} MiB"
    utilization_col = f"{stats['utilization']}%"

    # Calculate column widths based on content only
    fan_width = max(len("Fan"), len(fan_col))
    temp_width = max(len("Temp"), len(temp_col))
    power_width = max(len("Power"), len(power_col))
    util_width = max(len("Util."), len(utilization_col))
    mem_used_width = max(len("Mem Used"), len(mem_used_col))
    mem_total_width = max(len("Mem Total"), len(mem_total_col))

    # Build first table with 1 space padding on each side
    output.append(f" {'Fan':<{fan_width}} │ {'Temp':<{temp_width}} │ {'Power':<{power_width}} │ {'Util.':<{util_width}} │ {'Mem Used':<{mem_used_width}} │ {'Mem Total':<{mem_total_width}} ")
    output.append("─" * (fan_width + 2) + "┼" + "─" * (temp_width + 2) + "┼" + "─" * (power_width + 2) + "┼" + "─" * (util_width + 2) + "┼" + "─" * (mem_used_width + 2) + "┼" + "─" * (mem_total_width + 2))
    output.append(f" {fan_col:<{fan_width}} │ {temp_col:<{temp_width}} │ {power_col:<{power_width}} │ {utilization_col:<{util_width}} │ {mem_used_col:<{mem_used_width}} │ {mem_total_col:<{mem_total_width}} ")

    # Calculate total width of first table for second table consistency
    total_width = fan_width + temp_width + power_width + util_width + mem_used_width + mem_total_width + 18  # 18 for separators and padding

    output.append("")

    # Process table with widths that don't exceed first table
    pid_width = 6
    type_width = 4
    memory_width = 10
    process_width = total_width - pid_width - type_width - memory_width - 14 + 3  # 14 for separators and padding, +3 for more chars, +10 additional

    output.append(f" {'PID':<{pid_width}} │ {'Type':<{type_width}} │ {'Process':<{process_width}} │ {'Memory':<{memory_width}} ")
    output.append("─" * (pid_width + 2) + "┼" + "─" * (type_width + 2) + "┼" + "─" * (process_width + 2) + "┼" + "─" * (memory_width + 2))

    for pid, process, memory in processes:
        # Truncate process name if too long, showing end instead of beginning
        if len(process) > process_width:
            process_short = "..." + process[-(process_width-3):]
        else:
            process_short = process
        output.append(f" {pid:<{pid_width}} │ {'G':<{type_width}} │ {process_short:<{process_width}} │ {memory:<{memory_width}} ")

    if not processes:
        output.append(f"{'No GPU processes found':<{total_width}}")

    output.append("")
    return "\n".join(output)

def display_plain_text(content: str):
    """Display plain text content"""
    print(content)

def main():
    """Main function"""
    if not check_dependencies():
        sys.exit(1)

    try:
        content = format_plain_text()
        display_plain_text(content)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()