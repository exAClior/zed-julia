# Julia Textobjects for Zed - Implementation Plan

## Analysis of Translation Patterns

After analyzing the nvim-treesitter, Helix, and Zed examples, I've identified the following key translation patterns:

### 1. Naming Convention
- **nvim-treesitter**: Uses `.outer` and `.inner` with complex `#make-range!` predicates
- **Helix/Zed**: Uses `.around` and `.inside` with simpler captures
- **Translation**: Replace all `.outer` → `.around` and `.inner` → `.inside`

### 2. Function Body Patterns
- **nvim**: `#make-range!` to define body range excluding signature
- **Zed**: Direct capture like `body: (_) @function.inside` or `(_)? @function.inside`
- **Pattern**: Julia's `function_definition` and `macro_definition` nodes have implicit bodies after the signature

### 3. Parameter Handling
- **nvim**: Complex comma handling with multiple `#make-range!` predicates
- **Helix**: Simple pattern: `((_) @parameter.inside . ","? @parameter.around) @parameter.around`
- **Zed**: Uses similar simple pattern as Helix
- **Translation**: Use Helix's approach which is already Zed-compatible

### 4. Comments
- **nvim**: Single `@comment.outer`
- **Helix/Zed**: Both `@comment.inside` and `@comment.around`, with `+` for consecutive lines
- **Pattern**: `(line_comment)+ @comment.around` groups consecutive line comments

### 5. Julia-Specific Features
- **Short function definitions**: Julia has `f(x) = 2x` syntax (assignment-based)
- **Arrow functions**: Julia has `x -> x^2` syntax
- **Test macros**: `@test`, `@testset`, etc. are important for test navigation
- **Abstract/Primitive types**: Julia has `abstract type` and `primitive type` in addition to `struct`

## Complete Julia textobjects.scm for Zed

```scheme
; Functions - regular function definitions
(function_definition
  (_)? @function.inside) @function.around

; Functions - short form definitions (f(x) = body)
; Match assignment where LHS is a call_expression
(assignment
  (call_expression)
  (operator)
  (_) @function.inside) @function.around

; Functions - arrow/lambda functions
(arrow_function_expression
  [
    (identifier)
    (argument_list)
  ]
  "->"
  (_) @function.inside) @function.around

; Macros - treated like functions
(macro_definition
  (_)? @function.inside) @function.around

; Classes - struct definitions
(struct_definition
  (_)? @class.inside) @class.around

; Classes - abstract type definitions
(abstract_definition
  (_)? @class.inside) @class.around

; Classes - primitive type definitions
(primitive_definition
  (_)? @class.inside) @class.around

; Classes - module definitions (treat as class-like containers)
(module_definition
  (_)? @class.inside) @class.around

; Parameters - in function parameter lists
(parameter_list
  [(identifier)
   (slurp_parameter)
   (optional_parameter)
   (typed_parameter)
   (tuple_expression)
   (interpolation_expression)
   (call_expression)]
  @parameter.inside . ","? @parameter.around) @parameter.around

; Parameters - in keyword parameters
(keyword_parameters
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

; Parameters - in argument lists (for function calls)
(argument_list
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

; Parameters - in type parameter lists
(type_parameter_list
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

; Parameters - in tuples
(tuple_expression
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

; Parameters - in vectors/arrays
(vector_expression
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

; Comments - line comments (consecutive lines grouped)
(line_comment)+ @comment.around

(line_comment) @comment.inside

; Comments - block comments
(block_comment)+ @comment.around

(block_comment) @comment.inside

; Tests - @test macros and related test macros
(macrocall_expression
  (macro_identifier
    (identifier) @_name
    (#match? @_name "^(test|test_throws|test_logs|inferred|test_deprecated|test_warn|test_nowarn|test_broken|test_skip)$"))
  (argument_list) @test.inside) @test.around

; Tests - @testset blocks
(macrocall_expression
  (macro_identifier
    (identifier) @_name
    (#eq? @_name "testset"))
  (_) @test.inside) @test.around

; Blocks - compound statements (begin...end blocks)
(compound_statement
  (_)* @block.inside) @block.around

; Blocks - quote blocks
(quote_statement
  (_)* @block.inside) @block.around

; Blocks - let blocks
(let_statement
  (_)* @block.inside) @block.around

; Conditionals - if statements
(if_statement
  (_)* @conditional.inside) @conditional.around

; Conditionals - elseif clauses
(elseif_clause
  (_)* @conditional.inside) @conditional.around

; Conditionals - else clauses
(else_clause
  (_)* @conditional.inside) @conditional.around

; Loops - for loops
(for_statement
  (_)* @loop.inside) @loop.around

; Loops - while loops
(while_statement
  (_)* @loop.inside) @loop.around

; Calls - function calls
(call_expression
  (argument_list
    (_)* @call.inside)) @call.around

; Calls - macro calls
(macrocall_expression
  (argument_list
    (_)* @call.inside)) @call.around

; Calls - broadcast calls
(broadcast_call_expression
  (argument_list
    (_)* @call.inside)) @call.around
```

## Key Design Decisions

### 1. Simplification Strategy
I translated nvim's complex `#make-range!` patterns to Zed's simpler capture style:
- **nvim**: Manually defines ranges with start/end anchors
- **Zed**: Lets the tree-sitter node structure define ranges naturally
- **Example**: Instead of capturing between signature and `end`, we just capture all children with `(_)* @function.inside`

### 2. Julia Short Function Syntax
Julia's `f(x) = body` syntax is captured via the `assignment` node where the left side is a `call_expression`. This is important because it's a very common Julia idiom.

### 3. Arrow Functions
Julia's lambda syntax `x -> x^2` is a first-class construct and needs dedicated support. The pattern matches both single identifier and parameter list forms.

### 4. Comprehensive Parameter Support
Julia has rich parameter syntax (typed, optional, slurp, keyword, etc.). I included all parameter contexts:
- Function parameter lists
- Keyword parameters
- Argument lists (call sites)
- Type parameters (generics)
- Tuples and vectors (Julia-specific collection initialization)

### 5. Test Support
Julia's testing ecosystem heavily uses macros like `@test` and `@testset`. These are treated as first-class textobjects for:
- Quick navigation between tests
- Selecting entire test blocks
- Works with Zed's test running features

### 6. Block and Control Flow
Included comprehensive support for:
- Generic blocks (`begin...end`, `quote...end`, `let...end`)
- Conditionals (`if...elseif...else...end`)
- Loops (`for...end`, `while...end`)

All use the simple `(_)* @block.inside` pattern to capture body contents.

### 7. Type System Support
Julia has three type definition forms:
- `struct` (concrete types)
- `abstract type` (abstract types)
- `primitive type` (primitive types)

All three are mapped to `@class.around` and `@class.inside` to maintain consistency with other languages.

### 8. Comments
Both line comments and block comments are supported with:
- Consecutive line comments grouped via `+` operator
- Individual captures for `@comment.inside`
- Multiple consecutive blocks captured for `@comment.around`

### 9. Module Support
Modules in Julia are similar to namespaces in other languages. I treat them as class-like containers for organization purposes.

## Julia-Specific Considerations

### What Makes Julia Different
1. **Multiple function definition styles**: Full `function...end`, short `f(x) = body`, and lambda `x -> body`
2. **Macro-heavy idioms**: Testing, string literals, and DSLs all use macros extensively
3. **Rich type system**: Abstract, primitive, and concrete types all need support
4. **Semicolon in parameters**: Julia uses `;` to separate positional from keyword arguments
5. **Broadcasting**: The `.` operator for element-wise operations is pervasive

### Patterns We Don't Capture
Some nvim-treesitter patterns were omitted:
- **Assignment textobjects**: Too granular for typical text editing, but could be added if needed
- **Regex literals**: Niche use case, omitted for simplicity
- Complex conditional/loop body ranges: Zed's simpler approach with `(_)*` captures the entire body, which is more predictable

### Testing Recommendations
After implementing, test with:
1. **Functions**: Long form, short form, and lambdas
2. **Types**: Structs, abstract types, modules
3. **Parameters**: Function parameters, keyword parameters, type parameters
4. **Comments**: Single lines, comment blocks, consecutive comments
5. **Tests**: `@test` expressions and `@testset` blocks
6. **Control flow**: Nested `if`, `for`, `while` blocks
7. **Calls**: Regular calls, macro calls, broadcast calls

### Future Enhancements
Consider adding if users request:
- String textobjects (for multiline strings)
- Assignment left/right side navigation
- Specific support for do-block syntax
- Entry textobjects for dictionary/named tuple literals

## Implementation Notes

The file should be created at:
```
/Users/yushengzhao/editor/zed-julia/languages/julia/textobjects.scm
```

This follows the same structure as other `.scm` query files already present in that directory (`highlights.scm`, `indents.scm`, `outline.scm`, etc.).
