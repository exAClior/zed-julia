# Julia REPL Integration - Complete Guide

A comprehensive guide for sending Julia code from Zed to a REPL session.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Features Overview](#features-overview)
- [Setup and Configuration](#setup-and-configuration)
- [Usage Guide](#usage-guide)
- [Technical Design](#technical-design)
- [Configuration Reference](#configuration-reference)
- [Troubleshooting](#troubleshooting)
- [Changelog](#changelog)

---

## Quick Start

Get up and running with Julia REPL integration in 5 minutes.

### Method 1: Using Zed's Built-in Terminal (Recommended)

This method uses Zed's native terminal and keyboard shortcuts to send code.

#### 1. Configure Keybindings

Add to `~/.config/zed/keymap.json`:

```json
[
  {
    "context": "Editor && vim_mode == normal && extension == jl",
    "bindings": {
      "z f": ["workspace::SendKeystrokes", "v a f"],
      "z s": ["workspace::SendKeystrokes", "v a c"]
    }
  },
  {
    "context": "Editor && extension == jl",
    "bindings": {
      "shift-enter": [
        "workspace::SendKeystrokes",
        "cmd-c ctrl-` cmd-v enter ctrl-`"
      ]
    }
  }
]
```

#### 2. Usage

1. Open a Julia file in Zed
2. Open the terminal panel with `ctrl-\``
3. Start Julia REPL in the terminal: `julia`
4. Select Julia code in your editor
5. Press `Shift-Enter` to send code to the REPL

**How it works:** The keybinding copies the selection (`cmd-c`), switches to terminal (`ctrl-\``), pastes (`cmd-v`), sends Enter, and switches back to the editor.

**Vim Mode Shortcuts:**
- `z f` - Select function and prepare for sending
- `z s` - Select code block and prepare for sending

### Method 2: Using tmux (Advanced)

For users who prefer tmux-based workflow.

#### 1. Start tmux with Julia

```bash
# Start tmux and split window
tmux new-session -s julia-dev
tmux split-window -h
julia  # In the right pane

# Get the pane ID
tmux list-panes -F '#{pane_id} #{pane_index}'
# Output: %0 0 (left pane), %1 1 (right pane with Julia)
```

#### 2. Copy script to your system

```bash
mkdir -p ~/.local/bin
cp ~/.local/share/zed/extensions/work/julia/scripts/send-to-tmux.sh ~/.local/bin/
chmod +x ~/.local/bin/send-to-tmux.sh
```

#### 3. Add task to Zed

Create/edit `.zed/tasks.json` in your project:

```json
[
  {
    "label": "Send to Julia REPL",
    "command": "sh",
    "args": ["-c", "~/.local/bin/send-to-tmux.sh"],
    "hide": "always",
    "env": {
      "SLIME_TMUX_PANE": ":.1"
    }
  }
]
```

**Important:** Change `":.1"` to match your Julia pane ID from step 1.

#### 4. Add keybinding

Add to `~/.config/zed/keymap.json`:

```json
[
  {
    "context": "Editor && (language == Julia)",
    "bindings": {
      "ctrl-enter": [
        "editor::Copy",
        {"task::Spawn": {"task_name": "Send to Julia REPL"}}
      ]
    }
  }
]
```

#### 5. Usage

1. Select Julia code in Zed
2. Press `Ctrl-Enter`
3. Code is sent to Julia REPL and executed

---

## Features Overview

### Method 1: Built-in Terminal

✅ **Advantages:**
- No external dependencies (no tmux required)
- Simple setup with just keybindings
- Works with Zed's native terminal
- Fast and lightweight
- Cross-platform (macOS, Linux, Windows)

⚠️ **Limitations:**
- Requires manual terminal panel management
- Uses clipboard as intermediary
- Terminal must be visible and have Julia running

### Method 2: tmux Integration

✅ **Advantages:**
- Mimics vim-slime functionality
- Can send to hidden tmux panes
- Production-ready script with error handling
- Supports multiple REPLs
- Debug mode for troubleshooting
- Works with any tmux-based REPL

⚠️ **Limitations:**
- Requires tmux installed and running
- Manual tmux pane configuration
- Uses clipboard as intermediary (Zed API limitation)

### Common Features

- ✅ Send code from Zed to Julia REPL
- ✅ One-keypress operation
- ✅ Multi-line code and functions
- ✅ Comprehensive error handling
- ✅ Works with Julia textobjects for smart selection

---

## Setup and Configuration

### Built-in Terminal Method

#### Basic Configuration

The minimal keybinding for sending code:

```json
{
  "context": "Editor && extension == jl",
  "bindings": {
    "shift-enter": [
      "workspace::SendKeystrokes",
      "cmd-c ctrl-` cmd-v enter ctrl-`"
    ]
  }
}
```

**Breakdown:**
1. `cmd-c` - Copy selection to clipboard
2. `ctrl-\`` - Toggle terminal panel (open/focus)
3. `cmd-v` - Paste into terminal
4. `enter` - Execute the code
5. `ctrl-\`` - Return focus to editor

#### Vim Mode Integration

For vim users, add these text object helpers:

```json
{
  "context": "Editor && vim_mode == normal && extension == jl",
  "bindings": {
    "z f": ["workspace::SendKeystrokes", "v a f"],  // Select function
    "z s": ["workspace::SendKeystrokes", "v a c"]   // Select code block
  }
}
```

**Usage in vim mode:**
1. Press `z f` to select a function
2. Press `Shift-Enter` to send it to REPL

#### Alternative: Non-executing Send

To send code without auto-executing (paste-only):

```json
{
  "context": "Editor && extension == jl",
  "bindings": {
    "ctrl-shift-enter": [
      "workspace::SendKeystrokes",
      "cmd-c ctrl-` cmd-v ctrl-`"
    ]
  }
}
```

### tmux Method Configuration

#### Environment Variables

Configure via task environment or shell:

```json
{
  "env": {
    "SLIME_TMUX_PANE": ":.1",         // Target pane (required)
    "SLIME_TMUX_SOCKET": "default",   // Socket name (optional)
    "SLIME_AUTO_ENTER": "1",          // Auto-execute (default: 1)
    "SLIME_DEBUG": "0"                // Debug mode (default: 0)
  }
}
```

#### Common Pane Identifiers

- `:.1` - Pane 1 in current window (recommended)
- `:.2` - Pane 2 in current window
- `%1` - Absolute pane ID
- `julia-dev:0.1` - Specific session:window.pane

#### Multiple REPLs

Create separate tasks for different languages:

```json
[
  {
    "label": "Send to Julia REPL",
    "command": "sh",
    "args": ["-c", "~/.local/bin/send-to-tmux.sh"],
    "env": { "SLIME_TMUX_PANE": ":.1" }
  },
  {
    "label": "Send to Python REPL",
    "command": "sh",
    "args": ["-c", "~/.local/bin/send-to-tmux.sh"],
    "env": { "SLIME_TMUX_PANE": ":.2" }
  }
]
```

Bind to different keys:

```json
{
  "context": "Editor && (language == Julia)",
  "bindings": {
    "ctrl-enter": ["editor::Copy", {"task::Spawn": {"task_name": "Send to Julia REPL"}}]
  }
},
{
  "context": "Editor && (language == Python)",
  "bindings": {
    "ctrl-enter": ["editor::Copy", {"task::Spawn": {"task_name": "Send to Python REPL"}}]
  }
}
```

---

## Usage Guide

### Basic Workflow

#### With Built-in Terminal

1. **Start Julia REPL:**
   - Press `ctrl-\`` to open terminal
   - Type `julia` and press Enter
   - Press `ctrl-\`` to return to editor

2. **Write Julia code** in your editor

3. **Send code to REPL:**
   - Select the code you want to run
   - Press `Shift-Enter`
   - The code executes in the REPL

#### With tmux

1. **Ensure tmux is running** with Julia REPL in a pane
2. **Write Julia code** in Zed
3. **Send code:**
   - Select code
   - Press `Ctrl-Enter`
   - Code appears and executes in Julia REPL

### Advanced Usage

#### Send Without Executing (tmux)

Create a separate task for paste-only mode:

```json
{
  "label": "Send to REPL (no execute)",
  "env": {
    "SLIME_AUTO_ENTER": "0"
  }
}
```

Use this when you want to review code in the REPL before execution.

#### Debugging (tmux)

Enable verbose output to see what's being sent:

```bash
SLIME_DEBUG=1 ~/.local/bin/send-to-tmux.sh
```

Example output:
```
[DEBUG] Socket: default, Pane: :.1
[DEBUG] Reading clipboard...
[DEBUG] Clipboard content (45 chars):
x = [1, 2, 3]
sum(x)
println("Done")
[DEBUG] Loading into tmux buffer...
[DEBUG] Pasting to pane :.1...
[DEBUG] Sending Enter key...
[SUCCESS] Sent 3 line(s) to pane :.1
```

---

## Technical Design

### Built-in Terminal Architecture

```
┌─────────────────────────────────────────────┐
│  Zed Editor                                 │
│  • User selects Julia code                 │
│  • Presses Shift-Enter                     │
│    ↓                                        │
│  Keybinding: workspace::SendKeystrokes     │
│  Sequence: cmd-c ctrl-` cmd-v enter ctrl-` │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  System Clipboard                           │
│  • Temporarily holds selected code          │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  Zed's Built-in Terminal Panel              │
│  • Receives focus via ctrl-`                │
│  • Code pasted and executed                 │
│  • Returns focus to editor                  │
└─────────────────────────────────────────────┘
```

**Key Design Decision:** Uses `workspace::SendKeystrokes` to simulate a sequence of user actions (copy, switch to terminal, paste, execute, switch back). This approach requires no external scripts or tmux.

### tmux Architecture

```
┌─────────────────────────────────────────────┐
│  Zed Editor                                 │
│  • Select Julia code                       │
│  • Press Ctrl-Enter                        │
│    ↓                                        │
│  Copy to clipboard → Spawn task            │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  send-to-tmux.sh script                     │
│  • Reads clipboard (pbpaste/xclip)         │
│  • Validates tmux session/pane             │
│  • Sends via: load-buffer + paste-buffer   │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  tmux pane with Julia REPL                  │
│  julia> x = [1, 2, 3]                      │
│  julia> sum(x)                              │
│  15                                         │
└─────────────────────────────────────────────┘
```

### tmux Script Implementation

The `send-to-tmux.sh` script uses vim-slime's proven approach:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Configuration from environment
TMUX_SOCKET="${SLIME_TMUX_SOCKET:-default}"
TMUX_PANE="${SLIME_TMUX_PANE:-:.1}"

# Get clipboard content (cross-platform)
if [[ "$OSTYPE" == "darwin"* ]]; then
    CONTENT=$(pbpaste)
elif command -v xclip &> /dev/null; then
    CONTENT=$(xclip -selection clipboard -o)
elif command -v wl-paste &> /dev/null; then
    CONTENT=$(wl-paste)
else
    echo "Error: No clipboard utility found"
    exit 1
fi

# Send to tmux
tmux -L "$TMUX_SOCKET" load-buffer - <<< "$CONTENT"
tmux -L "$TMUX_SOCKET" paste-buffer -t "$TMUX_PANE"

# Optional: Auto-execute
if [ "${SLIME_AUTO_ENTER:-1}" = "1" ]; then
    tmux -L "$TMUX_SOCKET" send-keys -t "$TMUX_PANE" Enter
fi
```

**Why tmux?**
1. **Standard:** Ubiquitous in Unix development
2. **Reliable:** Well-documented IPC mechanism
3. **Flexible:** Works with any REPL (Julia, Python, R, etc.)
4. **Independent:** Not tied to Zed's terminal implementation
5. **Proven:** Same approach as vim-slime (battle-tested)

### API Limitations (Both Methods)

Due to Zed's extension API constraints:

1. **Clipboard dependency:** Cannot directly read editor selection
2. **No direct terminal text injection:** Must use clipboard + paste or keystroke simulation
3. **Manual configuration:** Cannot auto-detect REPL processes

These limitations are fundamental to Zed's current extension API and cannot be resolved without API changes.

---

## Configuration Reference

### Complete Keybinding Examples

#### Example 1: Minimal (Built-in Terminal)

```json
[
  {
    "context": "Editor && extension == jl",
    "bindings": {
      "shift-enter": [
        "workspace::SendKeystrokes",
        "cmd-c ctrl-` cmd-v enter ctrl-`"
      ]
    }
  }
]
```

#### Example 2: Vim Mode + Built-in Terminal

```json
[
  {
    "context": "Editor && vim_mode == normal && extension == jl",
    "bindings": {
      "z f": ["workspace::SendKeystrokes", "v a f"],
      "z s": ["workspace::SendKeystrokes", "v a c"]
    }
  },
  {
    "context": "Editor && extension == jl",
    "bindings": {
      "shift-enter": [
        "workspace::SendKeystrokes",
        "cmd-c ctrl-` cmd-v enter ctrl-`"
      ]
    }
  }
]
```

#### Example 3: tmux with Multiple REPLs

```json
[
  {
    "context": "Editor && (language == Julia)",
    "bindings": {
      "ctrl-enter": [
        "editor::Copy",
        {"task::Spawn": {"task_name": "Send to Julia REPL"}}
      ],
      "ctrl-shift-enter": [
        "editor::Copy",
        {"task::Spawn": {"task_name": "Send to REPL (no execute)"}}
      ]
    }
  }
]
```

### Complete Task Examples (tmux)

#### Example 1: Basic Task

```json
[
  {
    "label": "Send to Julia REPL",
    "command": "sh",
    "args": ["-c", "~/.local/bin/send-to-tmux.sh"],
    "hide": "always",
    "env": {
      "SLIME_TMUX_PANE": ":.1"
    }
  }
]
```

#### Example 2: With All Options

```json
[
  {
    "label": "Send to Julia REPL (Debug)",
    "command": "sh",
    "args": ["-c", "~/.local/bin/send-to-tmux.sh"],
    "hide": "always",
    "env": {
      "SLIME_TMUX_PANE": ":.1",
      "SLIME_TMUX_SOCKET": "default",
      "SLIME_AUTO_ENTER": "1",
      "SLIME_DEBUG": "1"
    }
  },
  {
    "label": "Send to REPL (no execute)",
    "command": "sh",
    "args": ["-c", "~/.local/bin/send-to-tmux.sh"],
    "hide": "always",
    "env": {
      "SLIME_TMUX_PANE": ":.1",
      "SLIME_AUTO_ENTER": "0"
    }
  }
]
```

### Settings Configuration

You can set environment variables globally in `~/.config/zed/settings.json`:

```json
{
  "terminal": {
    "env": {
      "SLIME_TMUX_SOCKET": "default",
      "SLIME_TMUX_PANE": ":.1",
      "SLIME_AUTO_ENTER": "1",
      "SLIME_DEBUG": "0"
    }
  }
}
```

---

## Troubleshooting

### Built-in Terminal Method

#### Issue: Code not executing

**Symptoms:** Pressing Shift-Enter does nothing

**Solutions:**
1. Ensure terminal panel is configured: Press `ctrl-\`` manually to verify it works
2. Check keybinding context matches your file (`.jl` extension)
3. Verify Julia REPL is running in the terminal
4. Test clipboard: Select text and press `cmd-c`, then `cmd-v` elsewhere

#### Issue: Terminal doesn't open

**Symptoms:** Terminal panel doesn't appear when pressing `ctrl-\``

**Solutions:**
1. Check if `ctrl-\`` is bound elsewhere in your keymap
2. Manually open terminal via command palette: `terminal panel: toggle`
3. Verify the keybinding in settings

#### Issue: Wrong terminal receives code

**Symptoms:** Code appears in wrong shell/terminal

**Solutions:**
1. Make sure Julia REPL is in the active terminal
2. Only one terminal should be open in the panel
3. Click on the terminal to ensure it's focused before sending code

### tmux Method

#### Error: "SLIME_TMUX_PANE not set"

**Solution:** Set the pane ID in your task configuration:

```json
{
  "env": {
    "SLIME_TMUX_PANE": ":.1"  // Add this
  }
}
```

#### Error: "Target pane not found"

**Solution:** Verify your pane ID:

```bash
tmux list-panes -a
```

Update your task with the correct pane ID.

#### Error: "tmux session not found"

**Solution:** Ensure tmux is running:

```bash
tmux ls
```

If no sessions exist, start one:

```bash
tmux new-session -s julia-dev
```

#### Error: "Clipboard is empty"

**Solution:** The keybinding must copy first, then send:

```json
"ctrl-enter": [
  "editor::Copy",  // ← This must come first!
  {"task::Spawn": {"task_name": "Send to Julia REPL"}}
]
```

#### Issue: Code sent but not executing (tmux)

**Solution:** Check `SLIME_AUTO_ENTER` setting:

```json
{
  "env": {
    "SLIME_AUTO_ENTER": "1"  // Must be "1" for auto-execute
  }
}
```

#### Issue: Clipboard utility not found (Linux)

**Solution:** Install a clipboard utility:

```bash
# Debian/Ubuntu
sudo apt-get install xclip

# or
sudo apt-get install xsel

# For Wayland
sudo apt-get install wl-clipboard
```

---

## Changelog

### v0.2.0 - REPL Integration Feature

#### New Files Added (9 total)

**Production Code:**
- `scripts/send-to-tmux.sh` - Production-ready tmux integration script
  - Cross-platform support (macOS/Linux)
  - Error handling and validation
  - Debug mode with detailed logging
  - Configurable via environment variables

**Documentation:**
- Consolidated comprehensive guide (this file)

**Templates:**
- `templates/tasks.json` - Pre-configured Zed tasks
- `templates/keymap.json` - Suggested keybindings (normal + vim mode)
- `templates/settings.json` - Environment variable configuration

#### Features

**tmux Method:**
- ✅ Send code to Julia REPL running in tmux
- ✅ One-keypress operation (Ctrl-Enter)
- ✅ Multi-line code and functions
- ✅ Auto-execute or paste-only modes
- ✅ Debug mode for troubleshooting
- ✅ Cross-platform (macOS/Linux)

**Built-in Terminal Method:**
- ✅ Send code to Zed's native terminal
- ✅ No external dependencies
- ✅ Simple keybinding configuration
- ✅ Vim mode integration
- ✅ Cross-platform (macOS/Linux/Windows)

#### Modified Files

- `README.md` - Added REPL integration section with quick start

#### Architecture

Both methods use clipboard as intermediary due to Zed API limitations, but provide different trade-offs:
- **Built-in Terminal:** Simpler, no tmux required, uses keystroke simulation
- **tmux:** More powerful, supports hidden panes, production-ready script

#### Comparison with vim-slime

| Feature | vim-slime | Zed (tmux) | Zed (built-in) |
|---------|-----------|------------|----------------|
| Send to tmux | ✅ | ✅ | ❌ |
| Send to terminal | ✅ | ❌ | ✅ |
| Visual selection | ✅ | ✅ (copy + send) | ✅ (seamless) |
| Multiple REPLs | ✅ | ✅ | ⚠️ (manual) |
| Auto-execute | ✅ | ✅ | ✅ |
| Paste-only mode | ✅ | ✅ | ⚠️ (custom binding) |
| Direct text access | ✅ | ⚠️ Via clipboard | ⚠️ Via clipboard |
| Auto-detect panes | ✅ | ❌ Manual config | N/A |
| External deps | None | tmux | None |

---

## Related Resources

### Documentation
- [Zed Tasks Documentation](https://zed.dev/docs/tasks)
- [Zed Keybindings Guide](https://zed.dev/docs/keybindings)
- [tmux Documentation](https://github.com/tmux/tmux/wiki)

### Inspiration
- [vim-slime](https://github.com/jpalardy/vim-slime) - Original vim REPL integration
- [iron.nvim](https://github.com/Vigemus/iron.nvim) - Neovim REPL interaction
- [nvim-smuggler](https://github.com/Klafyvel/nvim-smuggler) - Julia-specific Neovim plugin
- [VSCode Julia Extension](https://www.julia-vscode.org/) - Send to Terminal feature

### Contributing

Ideas for improvements:
- Better REPL auto-detection
- Cell execution support (`## %%` markers)
- Julia-specific text transformations
- Status feedback notifications
- Integration with LanguageServer.jl

See `CONTRIBUTING.md` for development guidelines.

---

## License

Same as the zed-julia extension (MIT License).
