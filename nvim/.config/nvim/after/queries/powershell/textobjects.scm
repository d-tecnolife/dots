; Function textobjects
(function_statement) @function.outer

(function_statement
  "{" @_start
  (script_block) @function.inner
  "}" @_end)

; Parameters
(function_parameter_declaration) @parameter.outer
