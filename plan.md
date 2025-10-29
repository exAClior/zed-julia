# Implementation Plan: Terminal REPL Integration with Smart Selection

**Approach**: Terminal Integration with Enhanced Textobjects  
**Branch**: `feature/comprehensive-repl-setup`  
**Estimated Effort**: 2-3 days  
**Date**: October 29, 2025

---

## Objective

Implement a seamless shift-enter REPL workflow that:
1. Automatically selects the innermost Julia construct at cursor position
2. Sends the selection to an integrated terminal running Julia REPL
3. Returns focus to the editor
4. Works for all major Julia constructs (functions, macros, structs, tests, modules, etc.)

---

## Core Strategy

Since Zed extensions **cannot** add custom keybindings or actions directly, we will:

1. **Enhance textobjects.scm**: Provide comprehensive tree-sitter queries for all Julia constructs
2. **Leverage vim mode**: Use vim textobjects for automatic selection
3. **Document keymap patterns**: Provide tested keybinding configurations for users
4. **Create usage guide**: Comprehensive documentation with examples and troubleshooting

---

## Architecture Overview

```
User Presses shift-enter
         ↓
Keymap (user's keymap.json) triggers
         ↓
workspace::SendKeystrokes chains:
  1. vim textobject selection (v a f / v a c / etc.)
  2. Copy to clipboard (cmd-c)
  3. Toggle terminal (ctrl-`)
  4. Paste and execute (cmd-v enter)
  5. Return to editor (ctrl-`)
         ↓
Enhanced textobjects.scm ensures correct selection
```

### Key Data Structures

**Textobject Query Structure**:
```scheme
(node_type
  (inner_content)? @construct.inside) @construct.around
```

Where:
- `@construct.inside`: Content without the definition/declaration
- `@construct.around`: Complete construct including definition

**Supported Textobject Types**:
- `@function.around` / `@function.inside`: Functions, macros, short functions
- `@class.around` / `@class.inside`: Structs, abstract types, primitives, modules
- `@test.around` / `@test.inside`: Test blocks (@test, @testset, etc.)
- `@comment.around` / `@comment.inside`: Comments
- `@parameter.around` / `@parameter.inside`: Function parameters

---

## Step-by-Step Implementation Plan

### **Phase 1: Enhanced Textobjects** (Day 1: 4-6 hours)

#### 1.1 Create Comprehensive textobjects.scm

**Location**: `languages/julia/textobjects.scm`

**Constructs to add** (based on tree-sitter grammar analysis):

```scheme
;; ======================
;; Functions and Macros
;; ======================
(function_definition (_)? @function.inside) @function.around
(short_function_definition (_)? @function.inside) @function.around
(macro_definition (_)? @function.inside) @function.around

;; ======================
;; Types and Structures
;; ======================
(struct_definition (_)? @class.inside) @class.around
(abstract_definition (_)? @class.inside) @class.around
(primitive_definition (_)? @class.inside) @class.around
(module_definition (_)? @class.inside) @class.around

;; ======================
;; Blocks and Statements
;; ======================
(compound_statement (_)? @function.inside) @function.around  ; begin/end blocks
(quote_statement (_)? @function.inside) @function.around     ; quote/end blocks
(let_statement (_)? @function.inside) @function.around       ; let/end blocks
(do_clause (_)? @function.inside) @function.around           ; do/end blocks

;; ======================
;; Control Flow
;; ======================
(if_statement (_)? @function.inside) @function.around
(for_statement (_)? @function.inside) @function.around
(while_statement (_)? @function.inside) @function.around
(try_statement (_)? @function.inside) @function.around

;; ======================
;; Parameters
;; ======================
(parameter_list
  ([(identifier)
    (slurp_parameter)
    (optional_parameter)
    (typed_parameter)
    (tuple_expression)
    (interpolation_expression)
    (call_expression)]
  @parameter.inside . ","? @parameter.around) @parameter.around)

(keyword_parameters
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

(argument_list
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

(type_parameter_list
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

;; ======================
;; Comments
;; ======================
(line_comment) @comment.inside
(line_comment)+ @comment.around
(block_comment) @comment.inside
(block_comment)+ @comment.around

;; ======================
;; Test Blocks
;; ======================
;; Matches @test, @testset, @test_throws, etc.
(_expression 
  (macro_identifier
    (identifier) @_name
    (#match? @_name "^(test|testset|test_throws|test_logs|inferred|test_deprecated|test_warn|test_nowarn|test_broken|test_skip)$")
  )
  .
  (macro_argument_list) @test.inside) @test.around
```

**Testing strategy**:
- Create test files with nested constructs
- Verify textobjects select correct ranges
- Test with vim commands: `vaf`, `vac`, `vif`, `vic`

#### 1.2 Fix @testset Issue

**Problem**: README notes that `@testset` macro syntax highlighting is broken

**Investigation needed**:
1. Check if tree-sitter grammar correctly parses `@testset`
2. Verify macro_identifier recognition
3. Test with actual @testset examples

**Files to check**:
- `languages/julia/highlights.scm`: Syntax highlighting
- Tree-sitter grammar node types

### **Phase 2: Keymap Configuration Examples** (Day 1-2: 3-4 hours)

#### 2.1 Create Comprehensive Keymap Guide

**Location**: Create new file `REPL_KEYBINDINGS.md`

**Content structure**:
```markdown
# Julia REPL Keybindings for Zed

## Prerequisites
- Vim mode enabled in Zed
- Julia REPL running in integrated terminal

## Basic Setup

### 1. Start Julia REPL
`ctrl-`` (toggle terminal)
`julia` (start REPL)

### 2. Configure Keymap
Edit `~/.config/zed/keymap.json`:
[Examples below]

## Keybinding Levels

### Level 1: Manual Selection (Simplest)
Works without vim mode, requires user to select code first.

### Level 2: Auto-Select Function (Recommended)
Uses vim textobjects to auto-select enclosing function.

### Level 3: Smart Selection (Advanced)
Multiple keybindings for different construct types.

### Level 4: Unified Selection (Expert)
Attempts multiple textobjects in order of specificity.
```

#### 2.2 Define Keybinding Patterns

**Pattern 1: Manual Selection** (no vim dependency)
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

**Pattern 2: Auto-Select Function** (requires vim mode)
```json
{
  "context": "Editor && (language == Julia) && vim_mode == normal",
  "bindings": {
    "shift-enter": [
      "workspace::SendKeystrokes",
      "v a f cmd-c escape ctrl-` cmd-v enter ctrl-` end"
    ]
  }
}
```

Breakdown:
- `v`: Enter visual mode
- `a f`: Around function (textobject)
- `cmd-c`: Copy
- `escape`: Exit visual mode
- `ctrl-``: Toggle terminal
- `cmd-v enter`: Paste and execute
- `ctrl-``: Return to editor
- `end`: Move to end of line (for next execution)

**Pattern 3: Multi-Key Dispatch** (expert)
```json
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
    "shift-enter t": [
      "workspace::SendKeystrokes",
      "v a t cmd-c escape ctrl-` cmd-v enter ctrl-`"
    ]
  }
}
```

Usage:
- `shift-enter f`: Send function
- `shift-enter c`: Send class/struct/module
- `shift-enter t`: Send test block

**Pattern 4: Line-Based** (fallback)
```json
{
  "context": "Editor && (language == Julia)",
  "bindings": {
    "shift-enter": [
      "workspace::SendKeystrokes",
      "V cmd-c escape ctrl-` cmd-v enter ctrl-`"
    ]
  }
}
```

Uses `V` (visual line mode) to select current line.

#### 2.3 macOS vs Linux Differences

**macOS keybindings**:
- Copy: `cmd-c`
- Paste: `cmd-v`
- Terminal toggle: `ctrl-``

**Linux keybindings**:
```json
{
  "context": "Editor && (language == Julia) && os == linux",
  "bindings": {
    "shift-enter": [
      "workspace::SendKeystrokes",
      "v a f ctrl-c escape ctrl-` ctrl-shift-v enter ctrl-` end"
    ]
  }
}
```

Note: Linux uses `ctrl-shift-v` for terminal paste.

### **Phase 3: Documentation** (Day 2: 4-5 hours)

#### 3.1 Create REPL Setup Guide

**Location**: `REPL_SETUP.md`

**Sections**:
1. **Overview**: What this provides
2. **Prerequisites**: System requirements
3. **Installation**: Step-by-step
4. **Configuration**: Keymap setup
5. **Usage**: Workflow examples
6. **Troubleshooting**: Common issues
7. **Advanced**: Power user tips

#### 3.2 Update README.md

Add new section:
```markdown
### REPL Integration

Zed-julia provides comprehensive textobjects for seamless REPL integration.
See [REPL_SETUP.md](./REPL_SETUP.md) for detailed setup instructions.

Quick start:
1. Enable vim mode in Zed
2. Start Julia REPL in terminal (`ctrl-``, then `julia`)
3. Configure keymap (see [REPL_KEYBINDINGS.md](./REPL_KEYBINDINGS.md))
4. Press `shift-enter` on any Julia function to execute it in REPL
```

#### 3.3 Create Examples Directory

**Location**: `examples/repl_workflow/`

**Files**:
- `basic_function.jl`: Simple function example
- `nested_structures.jl`: Complex nested code
- `test_workflow.jl`: Test-driven development example
- `module_development.jl`: Module creation workflow

Each file includes comments explaining the workflow.

#### 3.4 Troubleshooting Guide

**Common Issues**:

1. **Selection doesn't work**
   - Verify vim mode is enabled
   - Check textobject with manual `vaf` command
   - Ensure cursor is inside a valid construct

2. **Terminal doesn't receive code**
   - Check clipboard permissions
   - Verify terminal toggle keybinding
   - Ensure Julia REPL is running

3. **Code executes but cursor is in wrong place**
   - Adjust the ending keystroke in SendKeystrokes
   - May need `end` or `down` movement

4. **Multiline code doesn't paste correctly**
   - Julia REPL may need bracketed paste mode
   - Alternative: Use REPL's `include()` function

### **Phase 4: Testing** (Day 2-3: 3-4 hours)

#### 4.1 Textobject Tests

Create test suite:
```julia
# test/textobjects_test.jl

# Test 1: Simple function
function simple_func()
    return 42
end

# Test 2: Nested functions
function outer()
    function inner()
        return 1
    end
    return inner()
end

# Test 3: Short function definition
short_func(x) = x^2

# Test 4: Macro
macro test_macro(expr)
    return expr
end

# Test 5: Struct
struct MyStruct
    field1::Int
    field2::String
end

# Test 6: Module
module TestModule
    export test_func
    test_func() = println("test")
end

# Test 7: Test block
@testset "Basic tests" begin
    @test 1 + 1 == 2
    @test true
end

# Test 8: Control flow
for i in 1:10
    println(i)
end

# Test 9: Try-catch
try
    error("test")
catch e
    println("caught")
end

# Test 10: Do block
map(1:5) do x
    x^2
end
```

**Testing procedure**:
1. Open test file in Zed
2. Enable vim mode
3. Place cursor inside each construct
4. Execute `vaf` (or `vac`, etc.)
5. Verify correct selection range
6. Test shift-enter workflow

#### 4.2 Integration Tests

**Test scenarios**:
1. Fresh Zed install with vim mode
2. Existing Julia REPL in terminal
3. Multiple terminals open
4. Terminal not focused
5. Complex nested code
6. Code with syntax errors
7. Empty buffer
8. Multiple cursors (if supported)

#### 4.3 Cross-Platform Testing

Test on:
- [ ] macOS (primary platform)
- [ ] Linux (Ubuntu/Fedora)
- [ ] Windows (if Zed supports)

### **Phase 5: Polish & Release** (Day 3: 2-3 hours)

#### 5.1 Code Quality

- [ ] Format all scheme queries consistently
- [ ] Add comments explaining complex queries
- [ ] Verify no duplicate captures
- [ ] Check query performance on large files

#### 5.2 Documentation Quality

- [ ] Proofread all markdown files
- [ ] Verify all links work
- [ ] Test all keybinding examples
- [ ] Add screenshots/GIFs (optional but recommended)

#### 5.3 Update Existing Files

- [ ] Update `julia_repl_integration_plan.md` with actual implementation
- [ ] Update `CONTRIBUTING.md` if needed
- [ ] Check `extension.toml` version bump needed

#### 5.4 Create PR Description

**PR Title**: "feat: Add comprehensive textobjects and REPL integration guide"

**PR Description**:
```markdown
## Summary
Implements comprehensive textobjects for Julia constructs and provides
detailed REPL integration documentation.

## Changes
- Enhanced `textobjects.scm` with 20+ Julia constructs
- Created `REPL_SETUP.md` with step-by-step guide
- Created `REPL_KEYBINDINGS.md` with multiple keybinding patterns
- Added example workflows in `examples/repl_workflow/`
- Fixed @testset macro recognition issue

## Testing
- [x] Tested all textobjects with vim mode
- [x] Verified keybindings on macOS
- [x] Tested nested construct selection
- [x] Cross-platform testing (macOS/Linux)

## Documentation
- Comprehensive setup guide
- Multiple keybinding levels (beginner to expert)
- Troubleshooting section
- Example workflows

## Breaking Changes
None - this is purely additive functionality.

## Screenshots
[Add GIFs showing workflow]
```

---

## Success Metrics

### Must Have ✅
- [ ] Textobjects work for all major Julia constructs
- [ ] At least 2 working keybinding patterns documented
- [ ] Setup guide is clear and actionable
- [ ] Works on macOS with vim mode enabled

### Should Have 🎯
- [ ] Works on Linux
- [ ] Troubleshooting guide covers 80% of common issues
- [ ] Example workflows demonstrate real-world usage
- [ ] @testset issue is fixed

### Nice to Have ⭐
- [ ] Video/GIF demonstrations
- [ ] Performance benchmarks
- [ ] Community feedback incorporated
- [ ] Alternative patterns for non-vim users

---

## Risk Assessment & Mitigation

### Risk 1: Vim Mode Dependency
**Probability**: High  
**Impact**: High  
**Mitigation**: 
- Provide Pattern 1 (manual selection) for non-vim users
- Clearly document vim mode requirement
- Consider advocating for Zed to add custom actions API

### Risk 2: Clipboard Interference
**Probability**: Medium  
**Impact**: Medium  
**Mitigation**:
- Document that clipboard will be overwritten
- Suggest using kill ring if available
- Note in troubleshooting guide

### Risk 3: Terminal State Issues
**Probability**: Medium  
**Impact**: Medium  
**Mitigation**:
- Document requirement to have Julia REPL running
- Provide script to auto-start Julia in terminal
- Add detection in documentation

### Risk 4: Complex Multiline Code
**Probability**: High  
**Impact**: Low  
**Mitigation**:
- Test extensively with nested code
- Document limitations
- Suggest using IJulia for complex workflows

### Risk 5: Platform Differences
**Probability**: Medium  
**Impact**: Medium  
**Mitigation**:
- Provide separate keybindings for each OS
- Test on multiple platforms
- Community testing on Windows

---

## Implementation Order (Detailed)

### Day 1 Morning (4 hours)
1. ✅ Research complete
2. ✅ Plan created
3. ⏳ Enhance textobjects.scm
   - Add all function/macro constructs (30 min)
   - Add all class/struct/module constructs (30 min)
   - Add all block/statement constructs (45 min)
   - Add control flow constructs (30 min)
   - Add parameter selections (30 min)
   - Add test block selections (45 min)

### Day 1 Afternoon (4 hours)
4. Test textobjects with manual vim commands (2 hours)
5. Debug and fix any selection issues (1 hour)
6. Start keybinding documentation (1 hour)

### Day 2 Morning (4 hours)
7. Complete REPL_KEYBINDINGS.md (2 hours)
8. Create REPL_SETUP.md (2 hours)

### Day 2 Afternoon (4 hours)
9. Update README.md (1 hour)
10. Create example workflows (2 hours)
11. Create troubleshooting guide (1 hour)

### Day 3 Morning (3 hours)
12. Comprehensive testing with real workflows (2 hours)
13. Cross-platform testing (if possible) (1 hour)

### Day 3 Afternoon (2 hours)
14. Polish documentation (1 hour)
15. Create PR and submit (1 hour)

---

## Post-Implementation

### Community Engagement
1. Announce in Zed community
2. Announce in Julia Discourse
3. Gather feedback for v2

### Future Enhancements
1. Advocate for Zed custom action API
2. Consider Zed plugin for auto-start REPL
3. Explore integration with Zed's native REPL
4. Add more textobject types (loops, conditionals separately)

---

## Technical Considerations

### Tree-sitter Query Performance
- Large files may slow down parsing
- Consider adding anchors for efficiency
- Test with 1000+ line files

### Vim Mode Compatibility
- Verify compatibility with Zed's vim implementation
- Some vim commands may not be available
- Document any deviations from standard vim

### Keyboard Layout Support
- Current approach uses US keyboard layout
- May need adjustments for international layouts
- Document in troubleshooting

---

## Questions to Resolve

1. **Should we support Helix mode too?**
   - Helix uses same textobject concepts
   - May need different keybinding examples

2. **Should we include example .zed/tasks.json?**
   - Could provide task-based REPL launch
   - Alternative to manual terminal start

3. **Should we fix @testset in this PR or separate?**
   - Might be scope creep
   - But natural fit with test textobjects

4. **Video demonstration?**
   - Significantly improves adoption
   - Time investment worth it?

---

## Resources

- [Helix Julia Textobjects](https://github.com/helix-editor/helix/blob/master/runtime/queries/julia/textobjects.scm)
- [Tree-sitter Julia Grammar](https://github.com/tree-sitter/tree-sitter-julia)
- [Zed Vim Mode Docs](https://zed.dev/docs/vim)
- [Zed Keybindings Docs](https://zed.dev/docs/key-bindings)
- [GitHub Discussion #14058](https://github.com/zed-industries/zed/discussions/14058)

---

## Definition of Done

- [ ] All textobjects added to textobjects.scm
- [ ] All textobjects tested and working
- [ ] REPL_KEYBINDINGS.md created with 4+ patterns
- [ ] REPL_SETUP.md created with complete guide
- [ ] README.md updated with REPL section
- [ ] Example workflows created
- [ ] Troubleshooting guide written
- [ ] Tested on at least one platform (macOS)
- [ ] PR created with detailed description
- [ ] All tests passing
- [ ] Documentation reviewed for clarity

---

**Ready to implement? Let's start with Phase 1: Enhanced Textobjects!**
