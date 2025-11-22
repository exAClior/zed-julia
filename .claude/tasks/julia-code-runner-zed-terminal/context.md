# Feature: Julia Code Runner in Zed's Native Terminal

## Request
Implement a Julia code runner feature that allows executing Julia code directly in Zed's native terminal. This should provide a seamless experience for running Julia scripts, selected code blocks, and interactive Julia sessions.

## Project Status

### Current State
- **Project**: zed-julia extension (v0.1.8) - A Zed editor extension for Julia language support
- **Location**: `/Users/yushengzhao/editor/zed-julia`
- **Tech Stack**: Rust (using Zed Extension API v0.0.6)
- **Current Features**:
  - Language Server Protocol support via LanguageServer.jl
  - Tree-sitter syntax highlighting
  - One predefined task: "julia test" (runs `Pkg.test()`)
  - Custom completion label handling for Unicode characters

### Project Structure
```
zed-julia/
├── src/julia.rs              # Main extension implementation
├── extension.toml            # Extension metadata
├── Cargo.toml               # Rust dependencies
├── languages/julia/
│   ├── config.toml          # Language configuration
│   ├── tasks.json           # Task definitions (currently has 1 task)
│   ├── highlights.scm       # Syntax highlighting queries
│   ├── textobjects.scm      # Text object definitions
│   └── [other .scm files]   # Tree-sitter queries
└── README.md
```

### Existing Task Configuration
The extension has a basic tasks.json with one task:
- **julia test**: Runs package tests using `Pkg.test()`
- Uses environment variables like `$ZED_WORKTREE_ROOT`
- Sets Julia flags: `--startup-file=no`, `--history-file=no`

### Extension API
The extension implements the `zed::Extension` trait with:
- `language_server_command()`: Sets up LanguageServer.jl
- `label_for_completion()`: Custom completion labels for Unicode
- Uses `worktree.which("julia")` to locate Julia binary

## Zed Task System Capabilities

Based on [Zed Decoded: Tasks and Runnables](https://zed.dev/blog/zed-decoded-tasks#runnables):

### Task Definition Locations
- **Extension-level**: `languages/julia/tasks.json` (shipped with extension)
- **Project-level**: `.zed/tasks.json` in project root (user overrides)
- **Global-level**: `~/.config/zed/tasks.json` (user global tasks)

### Available Task Variables
- `$ZED_FILE`: Absolute path of currently open file
- `$ZED_ROW` and `$ZED_COLUMN`: Cursor position
- `$ZED_WORKTREE_ROOT`: Project root directory path
- `$ZED_SELECTED_TEXT`: Currently selected code
- `$ZED_SYMBOL`: Name of function/symbol containing cursor (Tree-sitter powered)

### Task Properties
- `label`: Display name
- `command`: Executable to run
- `args`: Command arguments (array)
- `use_new_terminal`: Boolean - spawn new terminal window
- `reveal`: When to show output (`always`, etc.)
- `cwd`: Working directory
- `tags`: Array of tags linking to runnables (e.g., `["julia-test"]`)

### Task Execution
- **Keyboard shortcuts**: `cmd-shift-p` → `task: spawn` opens task palette
- **Rerun last task**: `opt-t`
- **Context re-evaluation**: `reevaluate_context` option refreshes variables on each run (crucial for `$ZED_SELECTED_TEXT` workflows)

### Runnables System
**Implementation chain:**
1. Create `runnables.scm` with Tree-sitter query patterns
2. Queries tag syntax nodes (e.g., `@julia-test` for test functions)
3. Tasks reference these tags to link runnable buttons to task execution
4. Interactive play buttons appear in editor gutter

**Example flow:**
- Runnable query matches `@test function foo()` and tags it as `@julia-test`
- Task definition includes `"tags": ["julia-test"]`
- Play button appears next to test function, clicking runs the task

## Task Delegation
This task was delegated to the **julia-development** sub-agent, which specializes in Julia development and provides expert guidance on:
- Julia execution patterns and best practices
- Integration with Julia's REPL and package manager
- Proper handling of Julia environments and startup options
- Zed's task system and terminal integration

## Research & Planning Status
- [x] Initial context gathered
- [x] Research Zed's task/terminal capabilities
- [x] Research Julia execution patterns
- [x] Implementation plan created
- [x] Context updated with summary

## High-Level Summary

### Approach
The implementation will leverage Zed's **task system** (tasks.json) to provide comprehensive Julia code execution capabilities. The solution is designed in phases:

**Phase 1 (Core - Immediate Implementation):**
- 11 JSON-defined tasks covering file execution, selection evaluation, REPL startup, testing, and package management
- Uses Zed's environment variables (`$ZED_FILE`, `$ZED_SELECTED_TEXT`, `$ZED_WORKTREE_ROOT`)
- Follows Julia best practices: `--project=` for environment activation, `--startup-file=no` for reproducibility, `--color=yes` for rich output

**Phase 2 (Enhanced - Optional):**
- Tree-sitter runnables (runnables.scm) for inline run buttons on tests, main functions, and scripts
- Tag-based linking between tree-sitter matches and task definitions

**Phase 3 (Future):**
- Persistent REPL integration (blocked on Zed API extension)
- Code cell support like Jupyter (blocked on API)

### Key Design Decisions

1. **No Rust Code Changes Required**: All functionality achievable through JSON configuration
2. **Project Environment Activation**: All tasks use `--project=$ZED_WORKTREE_ROOT` for correct dependency resolution
3. **Multiple Execution Modes**: File, selection, interactive REPL, test-specific, package management
4. **VS Code Compatibility**: Mimics julia-vscode workflows where possible (Shift-Enter for evaluation)
5. **Graceful Limitations**: Document workarounds for missing persistent REPL integration

### User Experience
- Discoverable via `task: spawn` command palette
- Keybindable for common workflows (Shift-Enter, Cmd-Shift-Enter, etc.)
- Inline run buttons on tests (Phase 2)
- Project-local overrides via `.zed/tasks.json`

### Testing Strategy
- Manual testing across diverse scenarios: simple scripts, packages, errors, Unicode, plotting
- Edge case coverage: no Project.toml, subdirectories, interactive input

### Files to Modify
- `languages/julia/tasks.json` (primary changes)
- `languages/julia/runnables.scm` (new file for Phase 2)
- `README.md` (usage documentation)
- `CHANGELOG.md` (version entry)

### Success Metrics
Users can execute Julia code with feature parity to basic VS Code workflows, all tasks handle errors gracefully, and documentation clearly explains usage patterns.

## Terminal Emulator Notes

### Current Status
- Current setup works

### Open Questions
1. **Port Listening Behavior**: Need to investigate why WezTerm and Kitty support directly listening to the port, but Alacritty does not
2. **Terminal Multiplexer**: Is Zellij a better substitute for tmux?
3. **Implementation Approach**: Do we absolutely have to rely on a shell script? Can we do it purely in Rust?

### TODO
- [ ] **Tmux Integration Task**: Create a task that opens a terminal within Zed and starts tmux
  - Should accept a parameter to determine which Project.toml to use
  - Default value: current working directory (`$ZED_WORKTREE_ROOT`)
  - Task should activate the Julia environment for the specified project
  - Example usage: User can specify custom project path or use default
