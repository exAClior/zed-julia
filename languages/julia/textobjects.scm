;; ============================================================================
;; Julia Textobjects for Zed Editor
;; ============================================================================
;; This file defines textobject queries for vim-style navigation in Julia code.
;; Supports: vaf (select around function), vif (select inside function),
;;           vac (select around class/struct), vic (select inside class), etc.
;;
;; Textobject types in Zed:
;;   @function.around - entire function/block definition
;;   @function.inside - function/block body (contents)
;;   @class.around    - entire type/module/struct definition
;;   @class.inside    - type/module/struct contents
;;   @comment.around  - entire comment block
;;   @comment.inside  - comment text without markers
;; ============================================================================

;; ============================================================================
;; Functions and Executable Blocks
;; ============================================================================

;; Regular function definitions
;; Example: function foo() ... end
(function_definition) @function.around

;; Short-form function definitions (parsed as assignments)
;; Example: foo(x) = x^2
(assignment
  (call_expression) @_lhs
  (#match? @_lhs "^[a-zA-Z_]")
) @function.around

;; Macro definitions
;; Example: macro foo(expr) ... end
(macro_definition) @function.around

;; Begin/end compound statements
;; Example: begin ... end
(compound_statement) @function.around

;; Quote blocks
;; Example: quote ... end
(quote_statement) @function.around

;; Let blocks
;; Example: let x=1, y=2 ... end
(let_statement) @function.around

;; Do blocks
;; Example: map(1:5) do x ... end
(do_clause) @function.around

;; ============================================================================
;; Control Flow Structures
;; ============================================================================

;; If statements (including elseif and else)
;; Example: if condition ... elseif ... else ... end
(if_statement) @function.around

;; For loops
;; Example: for i in 1:10 ... end
(for_statement) @function.around

;; While loops
;; Example: while condition ... end
(while_statement) @function.around

;; Try-catch-finally blocks
;; Example: try ... catch e ... finally ... end
(try_statement) @function.around

;; ============================================================================
;; Types, Structures, and Modules
;; ============================================================================

;; Struct definitions
;; Example: struct Foo ... end
(struct_definition) @class.around

;; Abstract type definitions
;; Example: abstract type Foo end
(abstract_definition) @class.around

;; Primitive type definitions
;; Example: primitive type Foo 8 end
(primitive_definition) @class.around

;; Module definitions
;; Example: module Foo ... end
(module_definition) @class.around

;; ============================================================================
;; Comments
;; ============================================================================

;; Single line comments (multiple consecutive lines treated as one block)
;; Example: # comment
(line_comment) @comment.inside
(line_comment)+ @comment.around

;; Block comments
;; Example: #= comment =#
(block_comment) @comment.inside
(block_comment) @comment.around

;; ============================================================================
;; Test Blocks (Julia Testing.jl macros)
;; ============================================================================
;; These capture @test, @testset, @test_throws, etc.
;; Example: @testset "name" begin ... end
;;
;; Note: This uses a more flexible pattern to match test-related macros.
;; The macro_identifier should match identifiers like "testset", "test", etc.

;; Match test-related macro calls
;; Uses macrocall_expression (the correct node type from grammar)
(macrocall_expression
  (macro_identifier
    (identifier) @_test_name)
  (#match? @_test_name "^(test|testset|test_throws|test_logs|inferred|test_deprecated|test_warn|test_nowarn|test_broken|test_skip)$")
) @function.around
