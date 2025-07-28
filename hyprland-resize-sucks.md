# The Hyprland Dwindle Layout Resizing Problem

## 1. The Goal: Intuitive Keyboard Resizing

The desired behavior is straightforward and common in other tiling window managers like (even!) the Cosmic Alpha from System76 (I know, right!). When multiple windows are tiled, a user should be able to resize the focused window from any edge using the keyboard.

For example, with three vertical windows `[A][B][C]` (assumes keybindings):
- Focusing window `[B]` and pressing `mod+alt+l` should expand its right edge, pushing `[C]` further right.
- Focusing window `[B]` and pressing `mod+alt+h` should shrink its left edge, pushing `[A]` further left.

This allows for resizing any window in any direction, regardless of its position.

## 2. The Problem: Keyboard Resizing is Unidirectional and Unpredictable

In Hyprland's `dwindle` layout, keyboard-based resizing does not work as described above. The direction of the resize is not determined by user intent (e.g., pressing `h` for left or `l` for right), but by the rigid structure of the underlying binary tree that organizes the windows.

This results in frustrating behavior where both `mod+alt+h` and `mod+alt+l` might only resize the window from the right, or only from the left, depending on how the window was created and where it sits in the layout tree.

## 3. The Paradox: Mouse Resizing Works Perfectly

Frustratingly, the exact desired functionality **already exists** within Hyprland. Holding `mod` and dragging a window border with the right mouse button allows for perfect, intuitive, bidirectional resizing of any edge.

This proves the core logic for this type of resizing is present in the compositor.

## 4. The Technical Reason for the Discrepancy

The difference in behavior is due to how Hyprland handles the two types of input:

-   **Mouse Resizing (`bindm`):** This is an **interactive and context-aware** process. When you click and drag, Hyprland uses the **mouse cursor's coordinates** to determine which specific window edge you intend to manipulate. It then applies the resize operation directly to that edge.

-   **Keyboard Resizing (`bind`):** This is a **discrete and context-free** command. A keybinding executes a dispatcher like `resizeactive -50 0`. This command simply tells Hyprland "make the active window 50 pixels narrower." It **does not and cannot specify which edge to move**. Without that critical context, the `dwindle` layout engine falls back to its default behavior: manipulating the window's node within the binary tree, which may not correspond to the user's intended direction.

## 5. Conclusion: A Missing Dispatcher

The core of the issue is that Hyprland's internal, context-aware resizing logic (used by the mouse) is **not exposed to the user** through a keyboard-accessible dispatcher.

For a script or a keybinding to achieve this, Hyprland would need to implement a new, more powerful dispatcher that allows specifying which edge to resize, for example: `resizeedge left -50`.

Until such a feature is added, no amount of scripting can solve this problem, as all scripts are fundamentally limited to using the same inadequate, context-free dispatchers available in the configuration file. This is a known and widely discussed limitation within the Hyprland community.