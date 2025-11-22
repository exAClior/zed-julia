# Task: Create comprehensive Julia textobjects.scm for Zed

## Objective
Create a complete `textobjects.scm` file for Julia in the zed-julia extension by translating and combining patterns from nvim-treesitter-textobjects and Helix.

## Background
The zed-julia extension currently lacks a `textobjects.scm` file. We have:
- nvim-treesitter Julia textobjects at: `/Users/yushengzhao/editor/nvim-treesitter-textobjects/queries/julia/textobjects.scm`
- Helix Julia textobjects at: `/Users/yushengzhao/editor/helix/runtime/queries/julia/textobjects.scm`
- Zed example textobjects at: `/Users/yushengzhao/editor/zed/crates/languages/src/{rust,python,go}/textobjects.scm`

## Format Differences

### Naming Convention
- **nvim-treesitter**: Uses `.outer` and `.inner` suffixes
- **Helix/Zed**: Uses `.around` and `.inside` suffixes

### Complexity
- **nvim-treesitter**: Uses complex `#make-range!` predicates to define ranges
- **Helix**: Simpler, more direct captures
- **Zed**: Very simple, similar to Helix, typically captures body directly with patterns like `body: (_) @function.inside`

## Translation Rules (from comparison)

From examining Rust and Python examples:

1. **Functions**:
   - nvim: `@function.outer`, `@function.inner` with `#make-range!`
   - Zed: `@function.around` for whole function, `body: (_) @function.inside` for body

2. **Classes/Types**:
   - nvim: `@class.outer`, `@class.inner` with `#make-range!`
   - Zed: `@class.around` for whole struct/type, `body: (_) @class.inside` for body

3. **Parameters**:
   - nvim: Complex comma-handling with `#make-range!`
   - Zed: Simple `((_) @parameter.inside . ","? @parameter.around) @parameter.around`

4. **Comments**:
   - nvim: `@comment.outer`
   - Zed: `@comment.around`, sometimes `@comment.inside` too

5. **Tests**:
   - Helix has special `@test.around`/`@test.inside` for test macros
   - Zed supports this pattern too (seen in Python)

## Additional Textobject Types in Zed/Helix
- `@entry.around`/`@entry.inside` - for collection entries
- `@test.around`/`@test.inside` - for test functions

## Task Requirements
1. Analyze nvim-treesitter Julia textobjects
2. Analyze Helix Julia textobjects
3. Understand Julia-specific syntax nodes from the tree-sitter grammar
4. Translate to Zed's simpler format using `.around`/`.inside` naming
5. Include all relevant textobject types:
   - `function.around`/`function.inside`
   - `class.around`/`class.inside` (for structs, abstract types, etc.)
   - `parameter.around`/`parameter.inside`
   - `comment.around`/`comment.inside`
   - `test.around`/`test.inside` (for @test macros)
   - Any Julia-specific patterns

## Output
The research agent should create a `plan.md` file with:
1. Analysis of the translation patterns
2. Complete Julia `textobjects.scm` content for Zed
3. Explanation of key design decisions

## Research Completed

**Status**: ✓ Complete

**Summary**: Analyzed nvim-treesitter Julia textobjects (262 lines, complex `#make-range!` patterns), Helix Julia textobjects (47 lines, simple `.around/.inside` style), and Zed examples (Rust, Python, Go). Created comprehensive `textobjects.scm` for Julia following Zed's simple capture style.

**Key Findings**:
1. **Translation approach**: Replace nvim's `#make-range!` predicates with simple `(_)* @scope.inside` captures
2. **Julia specifics**: Must handle 3 function forms (full, short `f(x)=body`, lambda `x->body`)
3. **Test support**: Included `@test` and `@testset` macros as first-class textobjects
4. **Type system**: Support for `struct`, `abstract type`, `primitive type`, and `module`
5. **Parameters**: Comprehensive coverage including typed, optional, slurp, keyword parameters

**Output**: Complete `textobjects.scm` with 140+ lines covering:
- Functions (3 forms) and macros
- Classes (structs, abstract types, primitive types, modules)
- Parameters (6 contexts: parameter lists, keywords, arguments, type params, tuples, vectors)
- Comments (line and block)
- Tests (`@test` expressions and `@testset` blocks)
- Blocks, conditionals, loops
- Function/macro/broadcast calls

**Next Step**: Parent agent should review plan.md, then implement by creating the file at `/Users/yushengzhao/editor/zed-julia/languages/julia/textobjects.scm`
