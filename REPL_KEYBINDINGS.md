# Julia REPL Keybindings for Zed Editor

This guide provides various keybinding patterns for sending Julia code from the editor to a running REPL in the integrated terminal.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Keybinding Levels](#keybinding-levels)
   - [Level 1: Manual Selection](#level-1-manual-selection-simplest)
   - [Level 2: Auto-Select Function](#level-2-auto-select-function-recommended)
   - [Level 3: Multi-Key Dispatch](#level-3-multi-key-dispatch-advanced)
   - [Level 4: Line-Based](#level-4-line-based-fallback)
4. [Platform-Specific Configurations](#platform-specific-configurations)
5. [Vim Textobject Reference](#vim-textobject-reference)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

1. **Zed Editor** installed
2. **Julia** installed and accessible from terminal
3. **Vim mode enabled** in Zed (for auto-selection features)
   - Go to: Settings → Vim Mode → Enable
4. **Julia REPL running** in Zed's integrated terminal

---

## Quick Start

### Step 1: Start Julia REPL

1. Open Zed
2. Press `ctrl-\`` to open integrated terminal
3. Type `julia` and press Enter
4. Keep terminal open

### Step 2: Configure Keymap

1. Open command palette: `cmd-shift-p` (macOS) or `ctrl-shift-p` (Linux)
2. Search for: `zed: open keymap`
3. Add one of the keybinding configurations below
4. Save the file

### Step 3: Use It!

1. Open a Julia file
2. Place cursor inside a function
3. Press `shift-enter`
4. Watch the code execute in the REPL!

---

## Keybinding Levels

Choose the level that best fits your workflow and experience.

### Level 1: Manual Selection (Simplest)

**Best for**: Users who don't use vim mode or prefer explicit control.

**How it works**: You manually select the code you want to run, then press `shift-enter`.

**Configuration** (`~/.config/zed/keymap.json`):

```json
[
  {
    "context": "Editor && (language == Julia)",
    "bindings": {
      "shift-enter": [
        "workspace::SendKeystrokes",
        "cmd-c ctrl-` cmd-v enter ctrl-`"
      ]
    }
  }
]
```

**Usage**:
1. Select the code you want to run (visual mode or mouse)
2. Press `shift-enter`
3. Code is copied, pasted to terminal, executed, and focus returns to editor

**Advantages**:
- ✅ Works without vim mode
- ✅ Simple and predictable
- ✅ Full control over what gets executed

**Disadvantages**:
- ❌ Requires manual selection every time
- ❌ More keystrokes overall

---

### Level 2: Auto-Select Function (Recommended)

**Best for**: Vim users who want automatic construct selection.

**How it works**: Automatically selects the enclosing function/construct when you press `shift-enter`.

**Configuration**:

```json
[
  {
    "context": "Editor && (language == Julia) && vim_mode == normal",
    "bindings": {
      "shift-enter": [
        "workspace::SendKeystrokes",
        "v a f cmd-c escape ctrl-` cmd-v enter ctrl-`"
      ]
    }
  }
]
```

**Keystroke breakdown**:
- `v` - Enter visual mode
- `a f` - Select "around function" (vim textobject)
- `cmd-c` - Copy selection
- `escape` - Exit visual mode
- `ctrl-\`` - Toggle terminal focus
- `cmd-v enter` - Paste and execute
- `ctrl-\`` - Return to editor

**Usage**:
1. Place cursor anywhere inside a function
2. Press `shift-enter` in normal mode
3. Entire function is selected, copied, and executed

**Advantages**:
- ✅ No manual selection needed
- ✅ Works for functions, loops, structs, modules
- ✅ Efficient workflow

**Disadvantages**:
- ❌ Requires vim mode
- ❌ Must be in normal mode

**Tip**: If you're in insert mode, add this keybinding to quickly switch:

```json
{
  "context": "Editor && (language == Julia) && vim_mode == insert",
  "bindings": {
    "shift-enter": [
      "workspace::SendKeystrokes",
      "escape v a f cmd-c escape ctrl-` cmd-v enter ctrl-` i"
    ]
  }
}
```

This version escapes to normal mode first, then performs the same actions, and returns to insert mode at the end.

---

### Level 3: Multi-Key Dispatch (Advanced)

**Best for**: Power users who want granular control over which construct type to send.

**How it works**: Use `shift-enter` followed by a letter to specify the construct type.

**Configuration**:

```json
[
  {
    "context": "Editor && (language == Julia) && vim_mode == normal",
    "bindings": {
      "shift-enter f": [
        "workspace::SendKeystrokes",
        "v a f cmd-c escape ctrl-` cmd-v enter ctrl-`"
      ],
      "shift-enter c": [
        "workspace::SendKeystrokes",
        "v a c cmd-c escape ctrl-` cmd-v enter ctrl-`"
      ],
      "shift-enter l": [
        "workspace::SendKeystrokes",
        "V cmd-c escape ctrl-` cmd-v enter ctrl-`"
      ]
    }
  }
]
```

**Usage**:
- `shift-enter f` - Send function
- `shift-enter c` - Send class/struct/module
- `shift-enter l` - Send current line

**Advantages**:
- ✅ Precise control
- ✅ Can handle ambiguous cursor positions
- ✅ Extensible for custom needs

**Disadvantages**:
- ❌ Two-key sequence (slightly slower)
- ❌ Need to remember the keys

---

### Level 4: Line-Based (Fallback)

**Best for**: Quick testing of single expressions or statements.

**How it works**: Sends the current line to the REPL.

**Configuration**:

```json
[
  {
    "context": "Editor && (language == Julia) && vim_mode == normal",
    "bindings": {
      "shift-enter": [
        "workspace::SendKeystrokes",
        "V cmd-c escape ctrl-` cmd-v enter ctrl-` j"
      ]
    }
  }
]
```

**Keystroke breakdown**:
- `V` - Enter visual line mode (selects entire line)
- `cmd-c` - Copy
- `escape` - Exit visual mode
- `ctrl-\`` - Toggle terminal
- `cmd-v enter` - Paste and execute
- `ctrl-\`` - Return to editor
- `j` - Move down to next line (ready for next execution)

**Usage**:
1. Place cursor on any line
2. Press `shift-enter`
3. Line is executed, cursor moves to next line

**Advantages**:
- ✅ Simple and fast
- ✅ Great for interactive exploration
- ✅ Automatically advances to next line

**Disadvantages**:
- ❌ Only works for single-line expressions
- ❌ Multiline constructs require manual selection

---

## Platform-Specific Configurations

### macOS

Use the configurations shown above (with `cmd-` prefix for copy/paste).

### Linux

Linux uses different keybindings for terminal paste. Replace `cmd-v` with `ctrl-shift-v`:

**Level 2 (Auto-Select Function) for Linux**:

```json
[
  {
    "context": "Editor && (language == Julia) && vim_mode == normal && os == linux",
    "bindings": {
      "shift-enter": [
        "workspace::SendKeystrokes",
        "v a f ctrl-c escape ctrl-` ctrl-shift-v enter ctrl-`"
      ]
    }
  }
]
```

**Key differences**:
- Copy: `ctrl-c` instead of `cmd-c`
- Paste in terminal: `ctrl-shift-v` instead of `cmd-v`

### Windows

Windows support in Zed is still evolving. Use the Linux configuration as a starting point and adjust as needed.

---

## Vim Textobject Reference

The zed-julia extension provides comprehensive textobjects for Julia code. Here's what each one selects:

### Function-like Objects (use `a f` or `i f`)

| Textobject | Selects | Example |
|------------|---------|---------|
| `v a f` | Around function | Entire `function...end` block |
| `v i f` | Inside function | Function body only |
| `v a f` | Around macro | Entire `macro...end` block |
| `v a f` | Around loops | Entire `for...end`, `while...end` |
| `v a f` | Around conditionals | Entire `if...end` block |
| `v a f` | Around try-catch | Entire `try...catch...end` |
| `v a f` | Around do-block | Entire `do...end` block |
| `v a f` | Around begin-block | Entire `begin...end` |
| `v a f` | Around let-block | Entire `let...end` |
| `v a f` | Around quote-block | Entire `quote...end` |

### Class-like Objects (use `a c` or `i c`)

| Textobject | Selects | Example |
|------------|---------|---------|
| `v a c` | Around struct | Entire `struct...end` |
| `v i c` | Inside struct | Struct body only |
| `v a c` | Around module | Entire `module...end` |
| `v i c` | Inside module | Module contents |
| `v a c` | Around abstract type | `abstract type...end` |
| `v a c` | Around primitive type | `primitive type...end` |

### Comment Objects

| Textobject | Selects |
|------------|---------|
| `v a [` | Around comment block |
| `v i [` | Comment text only |

### Usage Examples

**Select and send a function**:
```
# Cursor anywhere in function
v a f       # Select entire function
y           # Yank (copy)
# Then use terminal to paste
```

**Navigate between functions**:
```
]f          # Jump to next function
[f          # Jump to previous function
```

**Change function body**:
```
c i f       # Change inside function (deletes body, enters insert mode)
```

---

## Troubleshooting

### Issue: Code doesn't execute in REPL

**Symptoms**: Code is pasted but nothing happens, or get an error.

**Solutions**:
1. **Verify REPL is running**: Check that you see the `julia>` prompt
2. **Check terminal focus**: Terminal should be visible and active
3. **Test manually**: Try copying and pasting manually to verify REPL works
4. **Restart REPL**: Sometimes the REPL gets into a bad state
   ```julia
   julia> # Press Ctrl-C to interrupt
   julia> # Press Ctrl-D to exit
   # Then restart: julia
   ```

### Issue: Selection doesn't work / wrong code is selected

**Symptoms**: Wrong code block is selected, or nothing is selected.

**Solutions**:
1. **Verify vim mode**: Go to Settings → Vim Mode → Ensure it's enabled
2. **Check cursor position**: Make sure cursor is inside the construct
3. **Test textobject manually**: Try typing `vaf` in normal mode to see what gets selected
4. **Update extension**: Ensure you have the latest zed-julia version
5. **Try different textobject**: Use `vac` for structs/modules instead of `vaf`

### Issue: Terminal doesn't receive pasted code

**Symptoms**: Code copies but doesn't appear in terminal.

**Solutions**:
1. **Check clipboard permissions**: Ensure Zed has clipboard access
2. **Verify terminal keybinding**: Make sure `ctrl-\`` opens terminal
3. **Test clipboard**: Copy something manually and paste in terminal
4. **Platform-specific paste**:
   - macOS: Use `cmd-v`
   - Linux: Use `ctrl-shift-v`

### Issue: Multiline code pastes incorrectly

**Symptoms**: Multiline functions execute only partially or error.

**Solutions**:
1. **Julia bracketed paste mode**: Julia's REPL should handle multiline paste automatically
2. **Use manual selection**: For complex multiline code, select it manually first
3. **Alternative: Use `include()`**:
   ```julia
   # Save code to file, then in REPL:
   julia> include("mycode.jl")
   ```
4. **Check for syntax errors**: Ensure the code is syntactically complete

### Issue: Focus doesn't return to editor

**Symptoms**: After execution, terminal stays focused instead of returning to editor.

**Solutions**:
1. **Check keystroke sequence**: Ensure the final `ctrl-\`` is in the binding
2. **Timing issues**: Try adding a delay (Zed doesn't support this directly, but you can press `ctrl-\`` manually)
3. **Use alternative**:
   ```json
   "shift-enter": [
     "workspace::SendKeystrokes",
     "v a f cmd-c escape ctrl-` cmd-v enter cmd-shift-e"
   ]
   ```
   This uses `cmd-shift-e` to explicitly focus the editor.

### Issue: Works sometimes but not others

**Symptoms**: Inconsistent behavior.

**Solutions**:
1. **Mode awareness**: Make sure you're in the right vim mode (normal vs insert)
2. **Context specificity**: Check that `context` in keymap matches your situation
3. **Timing**: There might be race conditions with async operations
4. **Simplify**: Start with Level 1 (manual selection) to isolate the issue

### Issue: `shift-enter` does nothing

**Symptoms**: Pressing the key combination has no effect.

**Solutions**:
1. **Check keymap syntax**: Ensure JSON is valid (use a JSON validator)
2. **Reload keymap**: Restart Zed after editing keymap.json
3. **Check conflicts**: See if another binding is capturing `shift-enter`
   - Use `zed: open default key bindings` to see system defaults
4. **Try different key**: Test with a different key to isolate the issue
   ```json
   "cmd-shift-r": [...]  // Try this instead
   ```

---

## Advanced Tips

### Tip 1: Combine with Julia REPL features

Once code is in the REPL, you can use Julia's built-in features:

```julia
# Edit the last expression
julia> ^E  # (Ctrl-E)

# Search history
julia> ^R  # (Ctrl-R)

# Clear screen
julia> ^L  # (Ctrl-L)
```

### Tip 2: Create project-specific keybindings

You can use Zed's workspace settings to have different keybindings per project:

1. Create `.zed/settings.json` in your project
2. Add custom key bindings (Note: Zed doesn't support per-project keymaps yet, but you can use different contexts)

### Tip 3: Use with Revise.jl for live development

For the best development experience:

```julia
# In REPL:
using Revise
using MyPackage

# Now code you send will automatically update!
```

### Tip 4: Debugging workflow

For debugging, combine with Julia's debugging tools:

```julia
# In REPL:
using Debugger

# Send functions to REPL as normal, then:
julia> @enter my_function()
```

### Tip 5: Quick module reload

Add a keybinding for reloading modules:

```json
{
  "context": "Terminal",
  "bindings": {
    "cmd-r": [
      "workspace::SendKeystrokes",
      "using Revise; revise() enter"
    ]
  }
}
```

---

## See Also

- [REPL_SETUP.md](./REPL_SETUP.md) - Complete setup guide
- [README.md](./README.md) - Extension overview
- [Zed Vim Mode Documentation](https://zed.dev/docs/vim)
- [Zed Keybindings Documentation](https://zed.dev/docs/key-bindings)
- [Julia REPL Documentation](https://docs.julialang.org/en/v1/stdlib/REPL/)

---

**Questions or issues?** Please open an issue on the [zed-julia GitHub repository](https://github.com/JuliaEditorSupport/zed-julia/issues).
