# Julia REPL Integration Setup Guide

Complete guide for setting up an efficient Julia REPL workflow in Zed Editor.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation Steps](#installation-steps)
4. [Configuration](#configuration)
5. [Basic Usage](#basic-usage)
6. [Advanced Workflows](#advanced-workflows)
7. [Troubleshooting](#troubleshooting)
8. [FAQ](#faq)

---

## Overview

This setup enables a seamless Julia development workflow where you can:

- **Send code to REPL with a single keypress** (`shift-enter`)
- **Automatically select functions, structs, modules, and more**
- **Keep your hands on the keyboard** (no mouse required)
- **Get immediate feedback** from the REPL while editing

**Result**: A workflow similar to Jupyter notebooks but in your text editor!

---

## Prerequisites

### System Requirements

- **Operating System**: macOS, Linux, or Windows (with Zed support)
- **Zed Editor**: Version 0.165 or later (for textobjects support)
- **Julia**: Version 1.6 or later

### Skills

- Basic familiarity with Zed
- Understanding of Julia syntax
- **Optional but recommended**: Vim keybindings knowledge

---

## Installation Steps

### Step 1: Install Julia

If you haven't already, install Julia from [julialang.org/downloads](https://julialang.org/downloads/).

**Verify installation**:
```bash
julia --version
```

You should see output like: `julia version 1.10.0`

### Step 2: Install Zed Editor

Download and install Zed from [zed.dev](https://zed.dev/download).

### Step 3: Install zed-julia Extension

1. Open Zed
2. Open command palette: `cmd-shift-p` (macOS) or `ctrl-shift-p` (Linux/Windows)
3. Type: `zed: extensions`
4. Search for: `Julia`
5. Click **Install** on the "Julia" extension
6. Restart Zed (if prompted)

**Verify installation**:
- Open a `.jl` file
- Check that syntax highlighting works
- Language server should start automatically

### Step 4: Enable Vim Mode (Recommended)

For automatic code selection to work, enable vim mode:

1. Open Settings: `cmd-,` (macOS) or `ctrl-,` (Linux/Windows)
2. Search for: `vim mode`
3. Enable: **Vim Mode**
4. Restart Zed

**Verify**:
- Open any file
- Bottom-right corner should show: `-- NORMAL --` or `-- INSERT --`

---

## Configuration

### Configure Keymap

1. **Open keymap editor**:
   - Command palette → `zed: open keymap`
   - Or directly edit: `~/.config/zed/keymap.json`

2. **Choose your keybinding level** from [REPL_KEYBINDINGS.md](./REPL_KEYBINDINGS.md)

3. **Recommended starting configuration** (Level 2):

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
  },
  {
    "context": "Editor && (language == Julia) && vim_mode == insert",
    "bindings": {
      "shift-enter": [
        "workspace::SendKeystrokes",
        "escape v a f cmd-c escape ctrl-` cmd-v enter ctrl-` i"
      ]
    }
  }
]
```

**Linux users**: Replace `cmd-` with `ctrl-` and `cmd-v` with `ctrl-shift-v`.

4. **Save the file**

---

## Basic Usage

### Starting a REPL Session

1. **Open Zed** with your Julia project
2. **Open terminal**: Press `ctrl-\``
3. **Start Julia**: Type `julia` and press Enter
4. **Wait for prompt**: You should see `julia>`

### Sending Code to REPL

**Method 1: Auto-Select Function (Recommended)**

1. Open a Julia file with functions
2. Place cursor anywhere inside a function
3. Press `shift-enter`
4. Watch the function execute in the REPL!

**Example**:

```julia
function greet(name)
    println("Hello, $name!")
end

# Cursor anywhere in the function above
# Press shift-enter
# Function is sent to REPL automatically!
```

**Method 2: Manual Selection**

1. Select code (visual mode in vim, or use mouse)
2. Press `shift-enter`
3. Selection is executed in REPL

**Method 3: Line-by-Line**

Configure line-based execution (see REPL_KEYBINDINGS.md Level 4), then:

1. Place cursor on any line
2. Press `shift-enter`
3. Line executes, cursor moves to next line

### Basic Development Cycle

```
1. Write function in editor
      ↓
2. Press shift-enter to send to REPL
      ↓
3. Test function in REPL (manually or with more shift-enter)
      ↓
4. Edit function if needed
      ↓
5. Press shift-enter again (updated function now in REPL)
      ↓
6. Repeat until satisfied
```

---

## Advanced Workflows

### Workflow 1: Interactive Development with Revise.jl

**Why**: Automatically reload code changes without restarting REPL.

**Setup**:

1. Install Revise.jl:
   ```julia
   using Pkg
   Pkg.add("Revise")
   ```

2. Auto-load Revise on REPL startup:
   ```bash
   # Edit: ~/.julia/config/startup.jl
   try
       using Revise
   catch e
       @warn "Error initializing Revise" exception=(e, catch_backtrace())
   end
   ```

3. In your project REPL session:
   ```julia
   using Revise
   using MyPackage  # Your package
   ```

**Usage**:
- Edit any file in `MyPackage`
- Changes are automatically reflected in REPL
- No need to restart or manually reload!

**Benefit**: Makes interactive development extremely fast.

---

### Workflow 2: Test-Driven Development (TDD)

**Setup**: Configure keybinding for running tests.

Add to `keymap.json`:

```json
{
  "context": "Editor && (language == Julia)",
  "bindings": {
    "cmd-t": [
      "workspace::SendKeystrokes",
      "ctrl-` include(\"test/runtests.jl\") enter ctrl-`"
    ]
  }
}
```

**TDD Cycle**:
1. Write a failing test
2. Send test to REPL (`shift-enter` on `@testset` block)
3. Watch it fail
4. Implement function
5. Send function to REPL (`shift-enter`)
6. Re-run test (`cmd-t`)
7. Watch it pass!

**Example**:

```julia
# test/runtests.jl
using Test

@testset "Math functions" begin
    @test add(2, 2) == 4
    @test add(0, 0) == 0
end

# Cursor in testset, press shift-enter
# Test fails (add not defined)

# src/math.jl
function add(a, b)
    a + b
end

# Cursor in function, press shift-enter
# Now press cmd-t to re-run tests
# Tests pass!
```

---

### Workflow 3: Module Development

**For**: Developing Julia packages/modules.

**Setup**:

```julia
# In REPL:
using Revise
using Pkg
Pkg.activate(".")  # Activate your package
using YourPackage
```

**Development cycle**:

1. Edit module file
2. Save (Revise automatically reloads)
3. Test in REPL - changes are live!

**Sending module definitions**:

```julia
module MyModule
    export my_function
    
    function my_function()
        println("Hello from module!")
    end
end

# Select entire module (vac in vim mode)
# Press shift-enter
# Module is now defined in REPL!
```

---

### Workflow 4: Data Analysis Workflow

**For**: Interactive data exploration and analysis.

**Setup REPL**:

```julia
using DataFrames, Plots, Statistics
```

**Interactive workflow**:

```julia
# Load data
df = CSV.read("data.csv", DataFrame)

# Explore (send each line with shift-enter in line mode)
describe(df)
first(df, 5)
names(df)

# Transform (send function with shift-enter)
function clean_data(df)
    df = dropmissing(df)
    df = filter(row -> row.value > 0, df)
    return df
end

df_clean = clean_data(df)

# Visualize (send block with shift-enter)
begin
    histogram(df_clean.value, label="Values")
    xlabel!("Value")
    ylabel!("Count")
end
```

**Benefit**: Rapid iteration without managing notebook cells.

---

### Workflow 5: Debugging Workflow

**Using Debugger.jl**:

1. Install Debugger:
   ```julia
   using Pkg
   Pkg.add("Debugger")
   ```

2. In REPL:
   ```julia
   using Debugger
   ```

3. Send function to REPL as normal
4. Then debug:
   ```julia
   @enter my_function(args)
   ```

**Using built-in debugging**:

1. Add breakpoints with `@bp`:
   ```julia
   function my_function(x)
       y = x + 1
       @bp  # Breakpoint here
       return y * 2
   end
   ```

2. Send function to REPL
3. Call function - execution stops at breakpoint

---

### Workflow 6: Benchmark and Profiling

**Setup**:

```julia
using BenchmarkTools
using Profile
```

**Workflow**:

```julia
# Define function (send with shift-enter)
function slow_function(n)
    sum([i^2 for i in 1:n])
end

# Benchmark it (send with shift-enter)
@benchmark slow_function(10000)

# Optimize
function fast_function(n)
    sum(i^2 for i in 1:n)  # Generator instead of list
end

# Compare (send with shift-enter)
@benchmark fast_function(10000)

# Profile it
@profile slow_function(100000)
Profile.print()
```

**Benefit**: Immediate feedback on performance changes.

---

## Troubleshooting

### Common Issues

#### Issue: "julia: command not found"

**Cause**: Julia not in PATH.

**Solution**:

1. Find Julia installation:
   ```bash
   # macOS example:
   /Applications/Julia-1.10.app/Contents/Resources/julia/bin/julia
   ```

2. Add to PATH (in `~/.zshrc` or `~/.bashrc`):
   ```bash
   export PATH="/Applications/Julia-1.10.app/Contents/Resources/julia/bin:$PATH"
   ```

3. Restart terminal and Zed

#### Issue: Textobjects don't work

**Symptoms**: `vaf` doesn't select functions.

**Solutions**:

1. **Verify vim mode is enabled**:
   - Check bottom-right corner of Zed
   - Should show vim mode indicator

2. **Test manually**:
   - Open a Julia file with a function
   - Press `Esc` (ensure normal mode)
   - Type `vaf`
   - Should select entire function

3. **Check extension version**:
   - Make sure you have latest zed-julia
   - Extensions → Julia → Update

4. **Restart Zed**: Sometimes needed after updates

#### Issue: REPL doesn't start in terminal

**Symptoms**: Terminal opens but Julia doesn't start.

**Solutions**:

1. **Check terminal shell**:
   - Zed uses your default shell
   - Ensure Julia is accessible from that shell

2. **Test manually**:
   - Open terminal in Zed
   - Type `julia` manually
   - Fix any PATH issues

3. **Alternative: Use a script**:
   Create `~/.zed_julia_repl.sh`:
   ```bash
   #!/bin/bash
   export PATH="/path/to/julia/bin:$PATH"
   exec julia
   ```
   
   Then start with: `bash ~/.zed_julia_repl.sh`

#### Issue: Code executes but with errors

**Symptoms**: Code runs but produces unexpected errors.

**Common causes**:

1. **Incomplete multiline expressions**:
   - Make sure full function/block is selected
   - Check selection with `vaf` before sending

2. **Missing dependencies**:
   ```julia
   # In REPL, check what's loaded:
   julia> names(Main)
   
   # Load missing packages:
   julia> using MissingPackage
   ```

3. **Scope issues**:
   - Variables defined in REPL are in `Main` scope
   - Module code might have different scope

4. **Syntax errors**:
   - Check editor for syntax highlighting issues
   - Language server should show errors

---

## FAQ

### Can I use this without vim mode?

Yes! Use Level 1 keybindings (manual selection) from REPL_KEYBINDINGS.md. You'll need to select code manually before pressing `shift-enter`.

### Does this work with Jupyter notebooks?

This setup is an *alternative* to Jupyter notebooks. If you prefer notebooks, consider using Pluto.jl or IJulia instead.

However, you can use Zed's native REPL support which does support Jupyter kernels! See the main README for details.

### Can I use a different key than `shift-enter`?

Absolutely! Change the keybinding in your `keymap.json` to any key you prefer:

```json
"cmd-r": [...]  // Or any other key combination
```

### What about Windows support?

Windows support for Zed is still developing. The keybindings should work but you may need to adjust:
- Use `ctrl-` instead of `cmd-`
- Terminal behavior might differ

### Can I send code to a remote Julia session?

Not directly with this method (it uses the local terminal). For remote development:

1. Use Zed's remote development features (if available)
2. Or SSH into remote machine first, then run Julia
3. Or use Julia's distributed computing features

### How is this different from VS Code's Julia extension?

**Similarities**:
- Both support sending code to REPL
- Both use language servers
- Both support debugging

**Differences**:
- Zed is faster and more lightweight
- VS Code has more mature Julia integration
- This setup uses vim textobjects (more powerful selection)
- Zed has better performance for large files

**Choose Zed if**: You value speed, simplicity, and vim-style editing.

**Choose VS Code if**: You need mature tooling and extensive extensions.

### Can I customize which constructs are sent?

Yes! Edit `textobjects.scm` in the extension to add custom patterns. See [Tree-sitter documentation](https://tree-sitter.github.io/tree-sitter/) for query syntax.

### Does this work with IJulia?

This terminal-based approach is separate from IJulia. However, Zed also has native Jupyter kernel support! For that workflow:

1. Install IJulia: `using Pkg; Pkg.add("IJulia"); using IJulia; IJulia.installkernel("Julia")`
2. Use Zed's built-in `repl: run` command (see main README)

---

## Next Steps

### Master the Workflow

1. ✅ Complete this setup guide
2. ✅ Try all keybinding levels from REPL_KEYBINDINGS.md
3. ✅ Practice with example workflows
4. ✅ Customize keymap to your preferences
5. ✅ Integrate with your typical Julia workflow

### Learn More

- **Vim textobjects**: Learn more vim commands for efficient editing
- **Julia REPL**: Explore REPL features like help mode (`?`), shell mode (`;`), and package mode (`]`)
- **Zed extensions**: Explore other Zed features and extensions

### Share Your Experience

Found this useful? Have suggestions?

- ⭐ Star the [zed-julia repository](https://github.com/JuliaEditorSupport/zed-julia)
- 🐛 Report issues on GitHub
- 💬 Share your workflow in discussions
- 📝 Contribute improvements

---

## Additional Resources

- [REPL_KEYBINDINGS.md](./REPL_KEYBINDINGS.md) - Detailed keybinding reference
- [README.md](./README.md) - Extension overview
- [Julia Documentation](https://docs.julialang.org/)
- [Zed Documentation](https://zed.dev/docs)
- [Tree-sitter Julia Grammar](https://github.com/tree-sitter/tree-sitter-julia)
- [Revise.jl Documentation](https://timholy.github.io/Revise.jl/stable/)

---

**Happy Julia coding in Zed!** 🚀
