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
