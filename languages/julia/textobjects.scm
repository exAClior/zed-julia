; Functions - regular function definitions
(function_definition (_)? @function.inside) @function.around

; Functions - short form definitions (f(x) = body)
(short_function_definition (_)? @function.inside) @function.around

; Macros - treated like functions
(macro_definition (_)? @function.inside) @function.around

; Classes - struct definitions
(struct_definition (_)? @class.inside) @class.around

; Classes - abstract type definitions
(abstract_definition (_)? @class.inside) @class.around

; Classes - primitive type definitions
(primitive_definition (_)? @class.inside) @class.around

; Parameters - in function parameter lists
(parameter_list
  ([(identifier)
    (slurp_parameter)
    (optional_parameter)
    (typed_parameter)
    (tuple_expression)
    (interpolation_expression)
    (call_expression)]
  @parameter.inside . ","? @parameter.around) @parameter.around)

; Parameters - in keyword parameters
(keyword_parameters
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

; Parameters - in argument lists (for function calls)
(argument_list
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

; Parameters - in type parameter lists
(type_parameter_list
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

; Comments - line comments
(line_comment) @comment.inside

(line_comment)+ @comment.around

; Comments - block comments
(block_comment) @comment.inside

(block_comment)+ @comment.around

; Tests - @test macros and related test macros
(_expression (macro_identifier
    (identifier) @_name
    (#match? @_name "^(test|test_throws|test_logs|inferred|test_deprecated|test_warn|test_nowarn|test_broken|test_skip)$")
  )
  .
  (macro_argument_list) @test.inside) @test.around
