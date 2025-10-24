# Julia REPL Integration for Zed Editor - Implementation Plan

## Current Progress Summary

### What's Working
- **Tree-sitter integration**: Basic textobject selection is functional
- **Function selection**: `v a f` selects function definitions surrounding cursor line
- **Struct selection**: `v a c` selects struct definitions surrounding cursor line
- **Keymap automation**: Basic workflow to copy selected code to integrated terminal and execute
- **REPL launching**: Can start Julia REPL if not already running

### Current Limitations
- **Manual selection required**: Must remember different keybindings for different constructs
  - `v a f` for functions
  - `v a c` for structs
- **Limited construct support**: Only tested with functions and structs
- **No unified keybinding**: No single keybinding that works for all Julia code constructs

## Proposed Workflow Enhancement

### Desired Feature
When cursor is placed on any line in a Julia file, pressing `shift-enter` should:
1. Start a Julia REPL if it's not already running
2. Intelligently select the enclosing code construct (function, macro, struct, etc.)
3. Copy and paste the selected code into the REPL
4. Execute the code and return focus to the Julia file

### Key Requirements
- **Intelligent construct detection**: Automatically identify whether cursor is in function, macro, struct, or other executable block
- **Unified keybinding**: Single `shift-enter` keybinding for all cases
- **Seamless workflow**: No manual selection or context switching required

## Research: Helix Editor Implementation

### Helix Julia Textobjects Analysis
Helix editor has a comprehensive `textobjects.scm` file for Julia that provides unified textobject selection:

```scheme
;; Functions and macros
(function_definition (_)? @function.inside) @function.around
(short_function_definition (_)? @function.inside) @function.around
(macro_definition (_)? @function.inside) @function.around

;; Types and structures
(struct_definition (_)? @class.inside) @class.around
(abstract_definition (_)? @class.inside) @class.around
(primitive_definition (_)? @class.inside) @class.around

;; Parameters and arguments
(parameter_list ; Match all children of parameter_list *except* keyword_parameters
  ([(identifier) (slurp_parameter) (optional_parameter) (typed_parameter)
    (tuple_expression) (interpolation_expression) (call_expression)] @parameter.inside
   . ","? @parameter.around) @parameter.around)
(keyword_parameters
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)
(argument_list
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)
(type_parameter_list
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

;; Comments
(line_comment) @comment.inside
(line_comment)+ @comment.around
(block_comment) @comment.inside
(block_comment)+ @comment.around

;; Tests
(_expression
  (macro_identifier (identifier) @_name
    (#match? @_name "^(test|test_throws|test_logs|inferred|test_deprecated|test_warn|test_nowarn|test_broken|test_skip)$"))
  . (macro_argument_list) @test.inside) @test.around
```

### Key Insights from Helix
1. **Unified approach**: All similar constructs use the same textobject type (`@function.around`, `@class.around`)
2. **Comprehensive coverage**: Handles functions, macros, structs, abstract types, primitives
3. **Parameter handling**: Sophisticated parameter and argument list selection
4. **Test support**: Special handling for test macros

## Implementation Plan

### Phase 1: Enhance Textobjects
1. **Study Zed's Julia textobject implementation**
   - Examine current `textobjects.scm` in Zed's Julia extension
   - Compare with Helix's comprehensive approach
   - Identify gaps and improvement opportunities

2. **Create unified textobject queries**
   - Develop a unified query that captures all executable Julia constructs
   - Ensure the query can identify the closest enclosing construct to cursor position
   - Test with various Julia code patterns (nested functions, modules, etc.)

### Phase 2: Keymap Implementation
1. **Create smart selection function**
   ```javascript
   // Pseudocode for the selection logic
   function selectEnclosingConstruct(cursorPosition) {
     const constructs = [
       'function_definition',
       'macro_definition',
       'struct_definition',
       'abstract_definition',
       'primitive_definition',
       'module_definition'
     ];

     for (const construct of constructs) {
       const range = findEnclosingConstruct(cursorPosition, construct);
       if (range) return range;
     }

     // Fallback to current line if no enclosing construct found
     return getCurrentLineRange(cursorPosition);
   }
   ```

2. **Implement unified keybinding**
   - Map `shift-enter` to the smart selection function
   - Chain with existing copy-paste-execute workflow
   - Ensure focus management works correctly

### Phase 3: Advanced Features
1. **Context-aware selection**
   - Detect if cursor is in import statement, include it
   - Handle multi-line constructs properly
   - Deal with nested structures intelligently

2. **Error handling and edge cases**
   - Handle cases where no clear construct exists
   - Manage incomplete or malformed code
   - Provide user feedback for selection issues

3. **Performance optimization**
   - Ensure minimal latency for the selection process
   - Cache parsing results where beneficial

### Phase 4: Testing and Refinement
1. **Comprehensive testing**
   - Test with various Julia code patterns and styles
   - Verify behavior with nested constructs
   - Test edge cases and error conditions

2. **User experience refinement**
   - Gather feedback from actual usage
   - Fine-tune selection heuristics
   - Optimize workflow for different use cases

## Technical Considerations

### Tree-sitter Query Optimization
- Need efficient queries that can find the nearest enclosing construct
- Must handle large files without performance degradation
- Should respect Julia's unique syntax (multiple dispatch, etc.)

### Integration with Zed's Architecture
- Leverage Zed's existing selection and command infrastructure
- Ensure compatibility with Zed's multi-cursor and selection systems
- Maintain consistency with Zed's UX patterns

### Cross-platform Compatibility
- Ensure REPL integration works across different operating systems
- Handle path and environment variable differences
- Test with various Julia installations and versions

## Success Metrics
1. **Unified workflow**: Single `shift-enter` works for all Julia constructs
2. **Accuracy**: Correctly identifies and selects appropriate code blocks 95%+ of time
3. **Performance**: Selection and execution completes within 100ms
4. **Reliability**: Works consistently across different Julia code patterns
5. **User satisfaction**: Seamless experience that matches or exceeds VSCode/Jupyter functionality

## Next Steps
1. Research Zed's current Julia extension structure and textobject implementation
2. Examine existing tree-sitter queries and identify enhancement opportunities
3. Develop prototype unified selection logic
4. Implement and test with various Julia code examples
5. Refine based on testing results and user feedback

## Resources and References
- [Helix Julia textobjects.scm](https://github.com/helix-editor/helix/blob/master/runtime/queries/julia/textobjects.scm)
- Zed Editor documentation and extension API
- Tree-sitter Julia grammar implementation
- Julia language documentation for edge cases

---

*Last updated: 2025-10-24*
*Status: Planning phase - ready to begin implementation*