; Comments
(line_comment)+ @comment.around

(block_comment) @comment.around

; Functions
(function_definition) @function.around

(macro_definition) @function.around

; Classes (types)
(struct_definition) @class.around

(abstract_definition) @class.around

(primitive_definition) @class.around

(module_definition) @class.around
