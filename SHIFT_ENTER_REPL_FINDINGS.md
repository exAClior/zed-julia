# Shift-Enter REPL Integration - Research Findings and Implementation Plan

**Date**: October 29, 2025  
**Status**: Research Complete - Ready for Implementation Planning

## Executive Summary

This document summarizes research findings for implementing shift-enter REPL integration in the zed-julia extension. Two viable approaches have been identified, with recommendations based on Zed's architecture and capabilities.

---

## Research Findings

### 1. Current State of zed-julia Extension

#### What Exists
- **Tree-sitter textobjects** (`languages/julia/textobjects.scm`):
  - Function definitions: `@function.around`
  - Macro definitions: `@function.around`
  - Struct definitions: `@class.around`
  - Comment blocks: `@comment.around`

- **Language Server**: LanguageServer.jl integration via Rust WASM extension
- **Syntax highlighting**: Comprehensive Julia grammar support
- **Tasks**: Basic `julia test` task defined

#### What's Missing
- No keybindings for REPL interaction
- Limited textobject coverage (compared to Helix's comprehensive approach)
- No automatic construct selection logic
- No documentation for REPL workflow setup

### 2. Zed's Built-in Capabilities

#### Native REPL Support (IMPORTANT DISCOVERY)
Zed has **built-in Jupyter kernel support** that works with Julia:

- **Command**: `repl: run` (default: `ctrl-shift-enter` on macOS)
- **Capabilities**:
  - Run selections, lines, or code blocks
  - Cell mode support with `# %%` markers
  - Inline output display
  - Kernel management (`repl: sessions`, `repl: refresh kernelspecs`)
  
- **Requirements**:
  - Julia kernel installed via IJulia: `using IJulia; IJulia.installkernel("Julia")`
  - Extension installed (already done for zed-julia)

#### Keybinding System
- **User keymap**: `~/.config/zed/keymap.json`
- **Context-aware**: Can bind keys based on editor state (e.g., `"context": "Editor"`)
- **Action chaining**: `workspace::SendKeystrokes` allows simulating key sequences
- **Precedence**: User keymaps override default keymaps

#### Extension Limitations (CRITICAL)
Zed extensions **CANNOT**:
- ❌ Add custom keybindings (must be in user's keymap.json)
- ❌ Define custom actions via WASM
- ❌ Programmatically control terminals
- ❌ Provide custom commands that integrate with vim motions

Zed extensions **CAN**:
- ✅ Provide language servers
- ✅ Define tree-sitter grammars and queries
- ✅ Add syntax highlighting
- ✅ Define tasks
- ✅ Provide documentation

### 3. Proven Workarounds from Community

From GitHub Discussion #14058 (tasks -> send to terminal):

**Working keybinding pattern** (September 2024):
```json
{
  "context": "Editor",
  "bindings": {
    "shift-enter": [
      "workspace::SendKeystrokes",
      "cmd-c ctrl-` cmd-v enter cmd-shift-e cmd-shift-e down"
    ]
  }
}
```

**Breakdown**:
- `cmd-c`: Copy selection
- `ctrl-``: Toggle terminal focus (default Zed binding)
- `cmd-v`: Paste
- `enter`: Execute
- `cmd-shift-e`: Focus editor (repeated to ensure it works)
- `down`: Move cursor down one line

**Limitations**:
- Requires manual selection before pressing shift-enter
- Relies on system clipboard
- Terminal must already be running
- No automatic construct detection

---

## Proposed Approaches

### **Approach 1: Use Zed's Native REPL (RECOMMENDED)**

#### Overview
Leverage Zed's built-in Jupyter kernel support for Julia, which provides a more integrated experience than terminal-based REPL.

#### Advantages
✅ **Native integration**: Uses Zed's designed REPL infrastructure  
✅ **Rich output**: Displays plots, tables, and formatted output inline  
✅ **No clipboard dependency**: Direct kernel communication  
✅ **Cell mode**: Supports Jupyter-style `# %%` cell markers  
✅ **Maintained by Zed**: Benefits from upstream improvements  
✅ **Multi-language**: Works consistently across Python, R, TypeScript, etc.

#### Implementation Steps

1. **Enhance textobjects.scm** (in extension)
   - Add comprehensive Julia constructs from Helix
   - Include: functions, macros, structs, test blocks, modules

2. **Create user documentation** (in extension README)
   - Installation: `using IJulia; IJulia.installkernel("Julia")`
   - Verification: `repl: refresh kernelspecs` command
   - Usage: `repl: run` command

3. **Provide example keybindings** (user configuration)
   ```json
   {
     "context": "Editor && (language == Julia)",
     "bindings": {
       "shift-enter": "repl: run"
     }
   }
   ```

4. **Document cell mode workflow** (in extension README)
   ```julia
   # %% Load dependencies
   using DataFrames, Plots
   
   # %% Process data
   df = DataFrame(x=1:10, y=rand(10))
   
   # %% Visualize
   plot(df.x, df.y)
   ```

#### Limitations
- Requires IJulia kernel installation
- Users must understand cell mode for best experience
- Cannot send to existing Julia REPL in terminal

#### Effort Estimate
- **Extension changes**: 4-8 hours (textobjects + documentation)
- **User setup**: 5-10 minutes (one-time kernel install + keymap config)

---

### **Approach 2: Terminal Integration with Smart Selection**

#### Overview
Implement the workaround using `workspace::SendKeystrokes` with enhanced textobject selection for automatic construct detection.

#### Advantages
✅ **Works with existing REPL**: Uses standard Julia REPL in terminal  
✅ **Familiar workflow**: Matches IJulia/Python patterns  
✅ **No additional dependencies**: Just Julia itself

#### Implementation Steps

1. **Enhance textobjects.scm** (in extension)
   - Add all executable Julia constructs
   - Ensure proper nesting and precedence
   - Reference: [Helix textobjects](https://github.com/helix-editor/helix/blob/master/runtime/queries/julia/textobjects.scm)

2. **Create comprehensive keybinding examples** (documentation)
   
   **Basic version** (requires selection):
   ```json
   {
     "context": "Editor && (language == Julia)",
     "bindings": {
       "shift-enter": [
         "workspace::SendKeystrokes",
         "cmd-c ctrl-` cmd-v enter ctrl-`"
       ]
     }
   }
   ```
   
   **Advanced version** (auto-select function):
   ```json
   {
     "context": "Editor && (language == Julia) && vim_mode == normal",
     "bindings": {
       "shift-enter": [
         "workspace::SendKeystrokes",
         "v a f cmd-c ctrl-` cmd-v enter ctrl-` v"
       ]
     }
   }
   ```
   
   Breakdown:
   - `v a f`: Visual mode, select around function (vim textobject)
   - `cmd-c`: Copy
   - `ctrl-``: Toggle terminal
   - `cmd-v enter`: Paste and execute
   - `ctrl-``: Return to editor
   - `v`: Exit visual mode

3. **Document textobject usage** (in README)
   - `v a f`: Select function
   - `v a c`: Select struct/class
   - `v i f`: Select function contents (without definition)

4. **Provide setup guide** (documentation)
   - How to start Julia REPL in terminal
   - How to configure keymap
   - Troubleshooting common issues

#### Limitations
- **No true "automatic selection"**: Zed extensions cannot provide custom logic to detect "innermost construct"
- **Vim mode dependency**: Advanced auto-selection requires vim mode
- **Clipboard interference**: Uses system clipboard
- **Terminal state**: Must have Julia REPL already running
- **Error handling**: If no construct found, behavior is undefined
- **Multiline issues**: Complex expressions may not copy correctly

#### Effort Estimate
- **Extension changes**: 6-10 hours (comprehensive textobjects + documentation)
- **User setup**: 10-15 minutes (keymap config + understanding textobjects)

---

### **Approach 3: Hybrid Approach (OPTIMAL)**

#### Overview
Combine both approaches to provide maximum flexibility.

#### Strategy
1. **Default recommendation**: Use Zed's native REPL (`repl: run`)
2. **Alternative for power users**: Provide terminal integration keybindings
3. **Comprehensive textobjects**: Support both approaches

#### Implementation

**Extension changes**:
1. Enhance `textobjects.scm` with comprehensive Julia constructs
2. Update README with three sections:
   - **Quick Start**: Native REPL with `shift-enter` bound to `repl: run`
   - **Advanced**: Terminal integration with `workspace::SendKeystrokes`
   - **Expert**: Vim mode + textobjects for auto-selection

**Documentation structure**:
```markdown
## REPL Integration

### Recommended: Native Zed REPL
[Installation, keybindings, cell mode]

### Alternative: Terminal REPL
[Setup, keybindings, limitations]

### Textobjects Reference
[Complete guide to Julia textobjects]
```

#### Advantages
✅ **Flexibility**: Users choose based on their workflow  
✅ **Future-proof**: Benefits from Zed REPL improvements  
✅ **Gradual adoption**: Can start with native, move to terminal if needed  
✅ **Comprehensive**: Covers all use cases

---

## Comparison Matrix

| Feature | Native REPL | Terminal Integration | Hybrid |
|---------|-------------|---------------------|--------|
| **Setup complexity** | Medium (kernel install) | Low (just keymap) | Medium |
| **Rich output** | ✅ Yes | ❌ No | ✅ Yes |
| **Existing REPL** | ❌ Creates new | ✅ Uses existing | Both |
| **Extension changes** | Small | Medium | Medium |
| **User config** | Simple | Complex | Flexible |
| **Maintenance** | Zed upstream | User/extension | Both |
| **Auto-selection** | ✅ Built-in | ⚠️ Partial (vim) | ✅ Built-in |
| **Cell mode** | ✅ Yes | ❌ No | ✅ Yes |

---

## Recommendations

### For the Extension Developers

**Implement Approach 3 (Hybrid)** with the following priorities:

1. **Phase 1: Foundation** (1-2 days)
   - [ ] Enhance `textobjects.scm` with comprehensive Julia constructs
   - [ ] Create `REPL_SETUP.md` documentation file
   - [ ] Add tests for textobjects

2. **Phase 2: Documentation** (1 day)
   - [ ] Update README with REPL integration section
   - [ ] Provide keymap examples for both approaches
   - [ ] Create troubleshooting guide

3. **Phase 3: Polish** (0.5 days)
   - [ ] Add example workflows to README
   - [ ] Update existing plan document
   - [ ] Create GitHub issue template for REPL problems

### For Users (Immediate Action)

**Option A: Quick Start with Native REPL**
1. Install IJulia kernel:
   ```julia
   using Pkg
   Pkg.add("IJulia")
   using IJulia
   IJulia.installkernel("Julia")
   ```

2. Add to `~/.config/zed/keymap.json`:
   ```json
   [
     {
       "context": "Editor && (language == Julia)",
       "bindings": {
         "shift-enter": "repl: run"
       }
     }
   ]
   ```

3. Refresh kernels in Zed: `repl: refresh kernelspecs`

**Option B: Terminal Integration**
1. Add to `~/.config/zed/keymap.json`:
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

2. Start Julia REPL in terminal first: `ctrl-`` then type `julia`

---

## Implementation Checklist

### Can Be Done in Extension
- [ ] Enhance `languages/julia/textobjects.scm` with comprehensive constructs
- [ ] Add function selection: `(function_definition) @function.around`
- [ ] Add short function selection: `(short_function_definition) @function.around`
- [ ] Add macro selection: `(macro_definition) @function.around`
- [ ] Add struct selection: `(struct_definition) @class.around`
- [ ] Add module selection: `(module_definition) @class.around`
- [ ] Add test block selection: `(_expression (macro_identifier) @test.around)`
- [ ] Add parameter selection: `(parameter_list) @parameter.around`
- [ ] Create `REPL_SETUP.md` with comprehensive guide
- [ ] Update `README.md` with REPL section
- [ ] Add example workflows
- [ ] Create troubleshooting section

### Requires User Configuration
- [ ] Document keymap for native REPL
- [ ] Document keymap for terminal integration
- [ ] Provide examples for vim mode users
- [ ] Document IJulia installation
- [ ] Explain kernel management

### Cannot Be Done (Zed Limitations)
- ❌ Add keybindings directly in extension
- ❌ Implement "smart selection" logic without vim textobjects
- ❌ Automatically start Julia REPL in terminal
- ❌ Create custom actions for construct selection

---

## Next Steps

1. **Create new branch**: `feature/comprehensive-repl-setup`
2. **Implement enhanced textobjects**: Use Helix as reference
3. **Write documentation**: Focus on user experience
4. **Test workflows**: Verify both approaches work
5. **Update existing plan**: Revise `julia_repl_integration_plan.md`
6. **Create PR**: With comprehensive examples

---

## References

- [Zed REPL Documentation](https://zed.dev/docs/repl)
- [Zed Keybindings Documentation](https://zed.dev/docs/key-bindings)
- [GitHub Discussion #14058: tasks -> send to terminal](https://github.com/zed-industries/zed/discussions/14058)
- [Helix Julia Textobjects](https://github.com/helix-editor/helix/blob/master/runtime/queries/julia/textobjects.scm)
- [IJulia Documentation](https://julialang.github.io/IJulia.jl/stable/)

---

## Glossary

- **Textobject**: Tree-sitter query that defines selectable code structures
- **Kernel**: Jupyter kernel that executes code (e.g., IJulia for Julia)
- **REPL**: Read-Eval-Print Loop, interactive programming environment
- **Cell mode**: Jupyter-style code organization with `# %%` markers
- **Keymap**: User configuration file for custom keybindings
- **Context**: Condition under which a keybinding is active
