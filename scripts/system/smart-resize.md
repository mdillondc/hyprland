# Smart Resize for Hyprland

## The Problem

Hyprland's keyboard window resizing is fundamentally limited in the `dwindle` layout. Instead of allowing resizing windows from either edge (bi-directionally), it resizes based on the window's position in an internal binary tree structure.

This is primarily an issue for ultrawide monitor users who maintain more than two columns in their layout.

**Example:** Three windows in columns:

```
+-------+-------+-------+
|       |       |       |
|   A   |   B   |   C   |
|       |       |       |
+-------+-------+-------+
```

- Focusing window `B` and resizing it using regular resizing will resize from the left edge
- To expand its right edge, you must focus window `C` and shrink it to expand window `B` from the right
- This becomes unintuitive, especially when coming from environments that allow expanding/shrinking windows from any edge
- This becomes more confusing when adding more columns to the layout, as window `B` might suddenly resize from the right edge instead

**The paradox:** Mouse resizing works perfectly by allowing resizing from any edge.

## The Solution

`smart-resize.sh` solves this by simulating the required keypress and mouse movement to resize windows from desired edge.

## Usage

```bash
# Smart Resizing (CTRL + SUPER + ALT + hjkl)
bind = $mainMod ALT CTRL, h, exec, bash ~/.config/hypr/scripts/system/smart-resize.sh extend left 80 # Extend active window 80px left
bind = $mainMod ALT CTRL, j, exec, bash ~/.config/hypr/scripts/system/smart-resize.sh shrink left 80 # Shrink active window 80px left
bind = $mainMod ALT CTRL, k, exec, bash ~/.config/hypr/scripts/system/smart-resize.sh shrink right 80 # Shrink active window 80px right
bind = $mainMod ALT CTRL, l, exec, bash ~/.config/hypr/scripts/system/smart-resize.sh extend right 80 # Extend active window 80px right

# Regular Resizing (SUPER + ALT + hjkl)
bind = $mainMod ALT, h, resizeactive, -80 0
bind = $mainMod ALT, j, resizeactive, 0 80
bind = $mainMod ALT, k, resizeactive, 0 -80
bind = $mainMod ALT, l, resizeactive, 80 0
```

## Requirements

- `dotool` - Input simulation tool

## Limitations

Because `smart-resize.sh` simulates keypress and mouse movements, it is slightly slower than regular resizing. However, until Hyprland implements proper edge-specific keyboard dispatchers (like `resizeedge left -50`), this script works within current limitations by automating the functional mouse-based workaround.