# Implementation Plan: Julia Code Runner in Zed's Native Terminal

## Executive Summary

This plan outlines the implementation of a comprehensive Julia code runner feature for the zed-julia extension. The solution will leverage Zed's task system and tree-sitter-based runnables to provide multiple execution modes for Julia code, similar to VS Code's julia-vscode extension but adapted to Zed's architecture.

## Research Findings

### Zed's Task System Architecture

Zed uses a dual-layer approach for code execution:

1. **Static Tasks (tasks.json)**: JSON-defined tasks available to all users
2. **Dynamic Runnables (runnables.scm)**: Tree-sitter queries that detect runnable code patterns and display inline run buttons

**Key Capabilities:**
- Environment variables: `$ZED_FILE`, `$ZED_SELECTED_TEXT`, `$ZED_SYMBOL`, `$ZED_WORKTREE_ROOT`, `$ZED_FILENAME`, `$ZED_STEM`, `$ZED_ROW`, `$ZED_COLUMN`, etc.
- Task options: `use_new_terminal`, `allow_concurrent_runs`, `reveal`, `hide`, `show_summary`, `show_command`
- Tag-based linking between runnables and tasks
- Custom keybindings via `task::Spawn` in keymap.json

### Julia Execution Patterns (from VS Code)

VS Code's julia-vscode provides these execution modes:

1. **Execute Code Block**: Runs selected code or the top-level construct containing the cursor (preserves location info for `@__DIR__`, `@__FILE__`, relative `include()`)
2. **Execute Code Cell**: Runs code between `##` or `# %%` delimiters
3. **Execute File**: Runs entire file in REPL
4. **Run File in New Process**: Spawns fresh Julia process (no state contamination)

**Julia Startup Flags (Best Practices):**
- `--project=<path>`: Activate specific environment
- `--startup-file=no`: Skip `~/.julia/config/startup.jl` for reproducibility
- `--history-file=no`: Don't save REPL history (cleaner for task execution)
- `--threads=auto`: Enable multi-threading

### Tree-Sitter Julia Node Types

Based on outline.scm analysis, available node types include:
- `function_definition`: Both long-form (`function foo()...end`) and short-form (`foo(x) = 2x`)
- `macro_definition`: Macro definitions
- `module_definition`: Module blocks
- `struct_definition`: Struct types
- `macrocall_expression`: Macro invocations (useful for `@testset`, `@test`)
- `assignment`: Variable assignments and short function definitions
- `call_expression`: Function calls

### Competitive Analysis: Other Zed Extensions

**Python Extension Pattern:**
- Tasks for running files: `python3 $ZED_FILE`
- Tasks for running selections: `python3 -c "$ZED_SELECTED_TEXT"`
- Virtual environment management tasks
- `use_new_terminal: false` for quick execution

**Rust Extension Pattern:**
- Runnables for test functions (via `@test` attribute detection)
- Runnables for main functions
- Tags: `rust-test` linked to `cargo test $ZED_SYMBOL`

## Implementation Strategy

### Phase 1: Core Task Definitions (tasks.json)

Create a comprehensive set of tasks in `languages/julia/tasks.json` covering common Julia workflows.

#### 1.1 File Execution Tasks

**Task: "julia: Run File"**
```json
{
  "label": "julia: Run File",
  "command": "julia",
  "args": [
    "--project=$ZED_WORKTREE_ROOT",
    "--startup-file=no",
    "--color=yes",
    "$ZED_FILE"
  ],
  "use_new_terminal": true,
  "allow_concurrent_runs": false,
  "reveal": "always"
}
```

**Rationale:**
- Runs entire file in fresh Julia process
- Activates project environment at worktree root
- Opens new terminal for clean output
- `--color=yes`: Preserve Julia's colored output in terminal

**Task: "julia: Run File (No Project)"**
```json
{
  "label": "julia: Run File (No Project)",
  "command": "julia",
  "args": [
    "--startup-file=no",
    "--color=yes",
    "$ZED_FILE"
  ],
  "use_new_terminal": true,
  "allow_concurrent_runs": false,
  "reveal": "always"
}
```

**Rationale:**
- For standalone scripts not in a project
- Uses default Julia environment

#### 1.2 Code Selection Execution

**Task: "julia: Evaluate Selection"**
```json
{
  "label": "julia: Evaluate Selection",
  "command": "julia",
  "args": [
    "--project=$ZED_WORKTREE_ROOT",
    "--startup-file=no",
    "--color=yes",
    "-e",
    "$ZED_SELECTED_TEXT"
  ],
  "use_new_terminal": false,
  "allow_concurrent_runs": true,
  "reveal": "always",
  "reevaluate_context": true
}
```

**Rationale:**
- Quick evaluation of selected code
- Reuses terminal for rapid iteration
- Allows concurrent runs for experimentation
- **`reevaluate_context: true`**: Critical for refreshing `$ZED_SELECTED_TEXT` on each execution, enabling users to select different code and re-run with `opt-t`

**Limitation:** This approach spawns a new Julia process each time, so state is not preserved between executions. For true REPL-style interaction, users would need to use a persistent REPL (see Phase 3).

#### 1.3 Interactive REPL

**Task: "julia: Start REPL"**
```json
{
  "label": "julia: Start REPL",
  "command": "julia",
  "args": [
    "--project=$ZED_WORKTREE_ROOT",
    "--color=yes"
  ],
  "use_new_terminal": true,
  "allow_concurrent_runs": false,
  "reveal": "always"
}
```

**Rationale:**
- Starts persistent interactive Julia session
- Users can manually paste/type code
- Full REPL features (multi-line editing, help mode, package mode, shell mode)

**Task: "julia: Start REPL (Custom Threads)"**
```json
{
  "label": "julia: Start REPL (Custom Threads)",
  "command": "julia",
  "args": [
    "--project=$ZED_WORKTREE_ROOT",
    "--threads=auto",
    "--color=yes"
  ],
  "use_new_terminal": true,
  "allow_concurrent_runs": false,
  "reveal": "always"
}
```

**Rationale:**
- Enables multi-threading for parallel code
- `--threads=auto`: Uses all available cores

#### 1.4 Testing Tasks

**Task: "julia: Run Tests (Current Package)"** *(already exists, keep enhanced version)*
```json
{
  "label": "julia: Run Tests",
  "command": "julia",
  "args": [
    "--project=$ZED_WORKTREE_ROOT",
    "--startup-file=no",
    "--color=yes",
    "-e",
    "using Pkg; Pkg.test()"
  ],
  "use_new_terminal": true,
  "allow_concurrent_runs": false,
  "reveal": "always"
}
```

**Task: "julia: Run Current Test File"**
```json
{
  "label": "julia: Run Current Test File",
  "command": "julia",
  "args": [
    "--project=$ZED_WORKTREE_ROOT",
    "--startup-file=no",
    "--color=yes",
    "-e",
    "using Test; include(\"$ZED_FILE\")"
  ],
  "use_new_terminal": true,
  "allow_concurrent_runs": false,
  "reveal": "always"
}
```

**Rationale:**
- Runs individual test file in test/ directory
- Useful for rapid test-driven development

#### 1.5 Package Management Tasks

**Task: "julia: Instantiate Project"**
```json
{
  "label": "julia: Instantiate Project",
  "command": "julia",
  "args": [
    "--project=$ZED_WORKTREE_ROOT",
    "--startup-file=no",
    "-e",
    "using Pkg; Pkg.instantiate()"
  ],
  "use_new_terminal": false,
  "allow_concurrent_runs": false,
  "reveal": "always"
}
```

**Task: "julia: Update Dependencies"**
```json
{
  "label": "julia: Update Dependencies",
  "command": "julia",
  "args": [
    "--project=$ZED_WORKTREE_ROOT",
    "--startup-file=no",
    "-e",
    "using Pkg; Pkg.update()"
  ],
  "use_new_terminal": false,
  "allow_concurrent_runs": false,
  "reveal": "always"
}
```

**Task: "julia: Build Project"**
```json
{
  "label": "julia: Build Project",
  "command": "julia",
  "args": [
    "--project=$ZED_WORKTREE_ROOT",
    "--startup-file=no",
    "-e",
    "using Pkg; Pkg.build()"
  ],
  "use_new_terminal": false,
  "allow_concurrent_runs": false,
  "reveal": "always"
}
```

#### 1.6 Benchmarking and Profiling

**Task: "julia: Benchmark File"**
```json
{
  "label": "julia: Benchmark File",
  "command": "julia",
  "args": [
    "--project=$ZED_WORKTREE_ROOT",
    "--startup-file=no",
    "--color=yes",
    "-e",
    "using BenchmarkTools; include(\"$ZED_FILE\")"
  ],
  "use_new_terminal": true,
  "allow_concurrent_runs": false,
  "reveal": "always"
}
```

### Phase 2: Tree-Sitter Runnables (runnables.scm)

Create `languages/julia/runnables.scm` to provide inline run buttons for specific Julia constructs.

#### 2.1 Runnable Patterns

**Pattern 1: Test Functions**
```scheme
; Match @testset blocks
(macrocall_expression
  (macro_identifier "@" (identifier) @_testset_macro)
  (#eq? @_testset_macro "testset")
  (argument_list
    (string
      (string_content) @test-name))
  (do_clause)) @julia-testset

; Match individual @test macros
(macrocall_expression
  (macro_identifier "@" (identifier) @_test_macro)
  (#eq? @_test_macro "test")) @julia-test
```

**Pattern 2: Main Functions**
```scheme
; Match function definitions named "main"
(function_definition
  "function" @_keyword
  (signature
    (call_expression
      (identifier) @_function_name
      (#eq? @_function_name "main")
      (argument_list))))  @julia-main
```

**Pattern 3: Standalone Scripts**
```scheme
; Match files with shebang lines
(source_file
  (comment) @_shebang
  (#match? @_shebang "^#!.*julia")) @julia-script
```

**Pattern 4: Module Definitions**
```scheme
; Match module definitions with module name as runnable context
(module_definition
  ["module" "baremodule"]
  name: (identifier) @module-name) @julia-module
```

#### 2.2 Task-Runnable Linking

Tasks need corresponding `tags` to link to runnables:

**Task: "julia: Run Testset"**
```json
{
  "label": "julia: Run Testset",
  "command": "julia",
  "args": [
    "--project=$ZED_WORKTREE_ROOT",
    "--startup-file=no",
    "--color=yes",
    "-e",
    "using Test; include(\"$ZED_FILE\")"
  ],
  "tags": ["julia-testset"],
  "use_new_terminal": true,
  "reveal": "always"
}
```

**Task: "julia: Run Main"**
```json
{
  "label": "julia: Run Main",
  "command": "julia",
  "args": [
    "--project=$ZED_WORKTREE_ROOT",
    "--startup-file=no",
    "--color=yes",
    "$ZED_FILE"
  ],
  "tags": ["julia-main"],
  "use_new_terminal": true,
  "reveal": "always"
}
```

**Note:** The `@run` capture and `$ZED_SYMBOL` variable are only available in Zed's built-in languages, not extensions (as of current API). Extensions can only use tags to link runnables to tasks.

### Phase 3: Advanced Features (Future Enhancement)

These features would require Zed extension API enhancements:

#### 3.1 Persistent REPL Integration

**Goal:** Send code to existing REPL session (like VS Code's Shift+Enter)

**Blockers:**
- Zed extension API doesn't currently expose methods to:
  - Send text to existing terminal sessions
  - Track terminal session state
  - Implement "send to REPL" commands

**Workaround:** Users can:
1. Run "julia: Start REPL" task
2. Manually copy code and paste into REPL
3. Or use "julia: Evaluate Selection" (spawns new process each time)

**Future Implementation (if API becomes available):**
- Extend `julia.rs` with `send_to_repl()` method
- Add commands: `julia.sendToRepl`, `julia.sendFileToRepl`
- Use Zed's terminal API to pipe text to active REPL

#### 3.2 Code Cell Support

**Goal:** Support `##` or `# %%` cell delimiters like VS Code

**Blockers:**
- Requires extension API to:
  - Query editor text ranges
  - Parse cell boundaries
  - Execute text between delimiters

**Workaround:**
- Users can manually select cell content
- Use "julia: Evaluate Selection" task

**Future Implementation:**
- Add `cell_delimiters` configuration in `config.toml`
- Tree-sitter injection for cell markers
- Custom command to detect and execute cells

#### 3.3 Custom Environment Variables from Runnables

**Goal:** Extract function names, test names, etc. from tree-sitter captures

**Blockers:**
- Zed extension API restricts custom `$ZED_CUSTOM_*` variables to built-in languages
- Extensions can only use predefined variables

**Workaround:**
- Use `$ZED_SYMBOL` where available (limited to certain contexts)
- Fallback to file-level execution

**Future Implementation:**
- Wait for Zed API to expose custom capture-to-variable mapping for extensions

### Phase 4: User Configuration

#### 4.1 Recommended User Settings

Document these configurations in README.md:

**Zed's Built-in Task Shortcuts:**
- `cmd-shift-p` → `task: spawn`: Open task picker
- `opt-shift-t`: Spawn task (alternative)
- `opt-t`: Re-run last task with updated context
- `opt-return`: Start selected task
- `cmd-opt-return`: Run as ephemeral task (doesn't set as "last run")

**Recommended Custom Keybindings (~/.config/zed/keymap.json):**
```json
[
  {
    "context": "Editor && mode == full && !VimWaiting && !menu",
    "bindings": {
      "shift-enter": ["task::Spawn", {"task_name": "julia: Evaluate Selection"}],
      "cmd-shift-enter": ["task::Spawn", {"task_name": "julia: Run File"}],
      "cmd-shift-t": ["task::Spawn", {"task_name": "julia: Run Tests"}],
      "cmd-shift-r": ["task::Spawn", {"task_name": "julia: Start REPL"}]
    }
  }
]
```

**Rationale:**
- `Shift-Enter`: Quick evaluation (mimics VS Code Julia extension)
  - Combined with `opt-t` (re-run), enables rapid iteration on different selections
- `Cmd-Shift-Enter`: Run entire file
- `Cmd-Shift-T`: Standard test shortcut
- `Cmd-Shift-R`: Start REPL

#### 4.2 Project-Local Tasks

Users can override/extend tasks in `.zed/tasks.json`:

**Example: Custom Benchmark Setup**
```json
[
  {
    "label": "julia: Run Benchmarks",
    "command": "julia",
    "args": [
      "--project=.",
      "--startup-file=no",
      "-e",
      "using PkgBenchmark; benchmarkpkg(\"MyPackage\")"
    ],
    "use_new_terminal": true
  }
]
```

### Phase 5: Testing Strategy

#### 5.1 Manual Testing Checklist

**File Execution:**
- [ ] Run simple script (print("Hello"))
- [ ] Run script with dependencies (using DataFrames)
- [ ] Run script with command-line args
- [ ] Run script in subdirectory (test `@__DIR__` resolution)
- [ ] Run script with syntax errors (verify error reporting)

**Selection Execution:**
- [ ] Evaluate single-line expression
- [ ] Evaluate multi-line block
- [ ] Evaluate code with dependencies
- [ ] Evaluate code with syntax errors
- [ ] Verify no selection shows task as unavailable

**REPL:**
- [ ] Start REPL in project
- [ ] Start REPL with threads
- [ ] Verify project environment active (check `using Package`)
- [ ] Test multi-line editing
- [ ] Test help mode (`?`)
- [ ] Test package mode (`]`)
- [ ] Test shell mode (`;`)

**Testing:**
- [ ] Run `Pkg.test()` on valid package
- [ ] Run individual test file
- [ ] Verify test output formatting
- [ ] Test with failing tests

**Package Management:**
- [ ] Instantiate fresh project
- [ ] Update dependencies
- [ ] Build package with build.jl

**Runnables (if Phase 2 implemented):**
- [ ] Run button appears on `@testset` blocks
- [ ] Run button appears on `main()` functions
- [ ] Clicking run button executes correct task
- [ ] Multiple runnables in same file work independently

#### 5.2 Edge Cases

**Case 1: No Project.toml in worktree root**
- Task should gracefully fall back to default environment
- Consider using `--project=$ZED_DIRNAME` for scripts in subdirectories

**Case 2: Very long output**
- Zed terminal should handle streaming output
- Test with `for i in 1:10000; println(i); end`

**Case 3: Interactive input**
- Tasks with `readline()` should work in terminal
- Test with `name = readline(); println("Hello $name")`

**Case 4: Unicode characters**
- Test Julia's Unicode identifier support: `α = 1; β = 2; α + β`
- Verify terminal rendering

**Case 5: Plotting**
- Test with `using Plots; plot(sin, 0, 2π)` (should open separate window)
- Verify task completes even with plot window open

### Phase 6: Documentation

#### 6.1 README.md Updates

Add section:

```markdown
## Running Julia Code

The zed-julia extension provides several ways to execute Julia code:

### Quick Start

1. **Run File**: `Cmd+Shift+Enter` (or use task picker: `julia: Run File`)
2. **Evaluate Selection**: Select code, press `Shift+Enter`
3. **Start REPL**: `Cmd+Shift+R` for interactive session

### Available Tasks

Access via `task: spawn` command or keybindings:

- **julia: Run File** - Execute current file in fresh Julia process
- **julia: Evaluate Selection** - Run selected code
- **julia: Start REPL** - Launch interactive Julia session
- **julia: Run Tests** - Run package test suite
- **julia: Run Current Test File** - Execute individual test file
- **julia: Instantiate Project** - Install dependencies
- **julia: Update Dependencies** - Update all packages

### Configuration

Custom keybindings can be added to `~/.config/zed/keymap.json`:

```json
{
  "context": "Editor && mode == full",
  "bindings": {
    "shift-enter": ["task::Spawn", {"task_name": "julia: Evaluate Selection"}]
  }
}
```

Project-specific tasks can be defined in `.zed/tasks.json`.

### Environment Activation

All tasks automatically activate the Julia project at the worktree root using
`--project=$ZED_WORKTREE_ROOT`. For standalone scripts, use "julia: Run File (No Project)".

### Limitations

- **REPL Integration**: Currently, code cannot be sent to a persistent REPL session.
  Use "Evaluate Selection" for quick runs or manually paste into a running REPL.
- **Code Cells**: Cell-based execution (like Jupyter) is not yet supported.

See [Zed Tasks Documentation](https://zed.dev/docs/tasks) for advanced configuration.
```

#### 6.2 CHANGELOG.md Entry

```markdown
## [0.2.0] - 2025-XX-XX

### Added
- Comprehensive Julia code execution via Zed's task system:
  - File execution tasks with project environment activation
  - Code selection evaluation
  - Interactive REPL startup
  - Test running (package-level and file-level)
  - Package management tasks (instantiate, update, build)
  - Benchmarking support
- Tree-sitter runnables for inline test execution (if Phase 2 implemented)
- Documentation for code running workflows

### Changed
- Enhanced existing "julia test" task with better defaults
```

## Implementation Checklist

### Must-Have (Phase 1)
- [ ] Update `languages/julia/tasks.json` with all core tasks:
  - [ ] julia: Run File
  - [ ] julia: Run File (No Project)
  - [ ] julia: Evaluate Selection
  - [ ] julia: Start REPL
  - [ ] julia: Start REPL (Custom Threads)
  - [ ] julia: Run Tests (enhanced)
  - [ ] julia: Run Current Test File
  - [ ] julia: Instantiate Project
  - [ ] julia: Update Dependencies
  - [ ] julia: Build Project
  - [ ] julia: Benchmark File
- [ ] Test all tasks manually
- [ ] Update README.md with usage instructions
- [ ] Add CHANGELOG.md entry

### Nice-to-Have (Phase 2)
- [ ] Create `languages/julia/runnables.scm`
- [ ] Add tree-sitter patterns for:
  - [ ] @testset blocks
  - [ ] @test macros
  - [ ] main() functions
  - [ ] Shebang scripts
- [ ] Add tagged tasks for runnables
- [ ] Test runnable buttons appear correctly
- [ ] Document runnables feature

### Future Enhancements (Phase 3+)
- [ ] Persistent REPL integration (requires API extension)
- [ ] Code cell support (requires API extension)
- [ ] Custom environment variables from captures (requires API extension)

## Risk Assessment

### Low Risk
- **Phase 1 (Core Tasks)**: Uses stable Zed task API, well-documented, straightforward JSON configuration
- **Testing Strategy**: Manual testing sufficient for task execution

### Medium Risk
- **Phase 2 (Runnables)**: Tree-sitter queries can be fragile if Julia grammar changes
  - Mitigation: Use conservative patterns, test against tree-sitter-julia updates
  - Mitigation: Document tree-sitter version dependency

### High Risk (Deferred)
- **Phase 3 (REPL Integration)**: Requires unavailable API
  - Mitigation: Document limitation, propose feature request to Zed
  - Mitigation: Provide workarounds in documentation

## Success Criteria

1. **Functionality**: Users can run Julia files, selections, and tests from Zed
2. **Usability**: Tasks discoverable via `task: spawn`, keybindable
3. **Reliability**: Tasks handle errors gracefully, work across project structures
4. **Documentation**: README clearly explains workflows
5. **User Satisfaction**: Feature parity with basic VS Code Julia workflows (file/selection execution, REPL, testing)

## Language Idioms Summary

### Julia-Specific Considerations

1. **Project Environment Activation**
   - Always use `--project=` flag to activate correct environment
   - Worktree root is typical project location
   - Support `--project=.` for nested projects via user config

2. **Startup File Handling**
   - Use `--startup-file=no` for reproducible task execution
   - Allow users to override via custom tasks for personalized REPL

3. **Multi-Threading**
   - Provide separate task for `--threads=auto`
   - Julia's threading model requires startup-time flag, can't be changed at runtime

4. **Color Output**
   - Use `--color=yes` to preserve Julia's rich error messages and stack traces
   - Julia auto-detects TTY but explicit flag ensures consistency

5. **Testing Conventions**
   - Julia packages follow `test/runtests.jl` convention
   - `Pkg.test()` automatically finds and runs tests
   - Individual test files should `using Test` and be `include()`-able

6. **Include Path Resolution**
   - Julia's `include()` uses relative paths from calling file
   - Running via `-e "include(...)"` preserves `@__DIR__` semantics
   - Direct file execution (`julia file.jl`) also correct

7. **REPL Modes**
   - Help mode (`?`), Package mode (`]`), Shell mode (`;`) are essential Julia workflows
   - Tasks should use interactive terminal for REPL tasks
   - Non-interactive for quick execution

8. **Package Manager Commands**
   - `Pkg.instantiate()`: Install exact versions from Manifest.toml
   - `Pkg.update()`: Update to compatible versions per Project.toml
   - `Pkg.build()`: Run post-install build scripts (often for binary dependencies)

9. **Error Handling**
   - Julia prints rich stack traces with file:line information
   - Zed's terminal should make these clickable (verify)
   - Task failures should keep terminal open for inspection

10. **Performance Considerations**
    - Julia has compilation overhead on first run
    - Tasks spawning new processes will feel slow initially
    - Document this behavior vs. persistent REPL benefits

## Open Questions

1. **Q: Should we provide a task for Julia with compilation cache flags?**
   - A: Defer to Phase 3 or user customization. `--sysimage` and `--compiled-modules` are advanced.

2. **Q: How to handle multi-file projects where entry point isn't at root?**
   - A: Document project-local `.zed/tasks.json` overrides. Users can specify exact paths.

3. **Q: Should we integrate with julia-vscode's LanguageServer.jl task templates?**
   - A: No, we already use LanguageServer.jl for LSP. Tasks are independent.

4. **Q: Can we detect if user has Revise.jl and offer auto-reload tasks?**
   - A: No detection mechanism in Zed extension API. Document manual setup in README.

5. **Q: Should tasks validate Julia version or package presence before running?**
   - A: No, let Julia's error messages handle this. Tasks should be simple command runners.

## References

- [Zed Tasks Documentation](https://zed.dev/docs/tasks)
- [Zed Extension Language Guide](https://zed.dev/docs/extensions/languages)
- [VS Code Julia Extension - Running Code](https://www.julia-vscode.org/docs/dev/userguide/runningcode/)
- [Julia Manual - Command-line Interface](https://docs.julialang.org/en/v1/manual/command-line-interface/)
- [Tree-sitter Query Documentation](https://tree-sitter.github.io/tree-sitter/using-parsers/queries/)
- [tree-sitter-julia Repository](https://github.com/tree-sitter/tree-sitter-julia)

---

**Plan Status**: Complete and ready for parent agent execution
**Estimated Effort**:
- Phase 1: 2-3 hours (task definitions + testing + documentation)
- Phase 2: 3-4 hours (runnables.scm + testing)
- Phase 3: Blocked on API availability

**Next Steps**: Awaiting user approval to proceed with implementation.
