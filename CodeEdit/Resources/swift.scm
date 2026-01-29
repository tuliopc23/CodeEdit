; Keywords
(class_declaration "class" @keyword)
(struct_declaration "struct" @keyword)
(enum_declaration "enum" @keyword)
(protocol_declaration "protocol" @keyword)
(extension_declaration "extension" @keyword)
(function_declaration "func" @keyword)
(init_declaration "init" @keyword)
(deinit_declaration "deinit" @keyword)
(import_declaration "import" @keyword)
(variable_declaration "var" @keyword)
(variable_declaration "let" @keyword)
(typealias_declaration "typealias" @keyword)

(if_statement "if" @keyword)
(guard_statement "guard" @keyword)
(else "else" @keyword)
(for_statement "for" @keyword)
(while_statement "while" @keyword)
(repeat_while_statement "repeat" @keyword)
(repeat_while_statement "while" @keyword)
(return_statement "return" @keyword)
(throw_statement "throw" @keyword)
(do_statement "do" @keyword)
(catch_clause "catch" @keyword)
(switch_statement "switch" @keyword)
(case_label "case" @keyword)
(default_label "default" @keyword)
(where_clause "where" @keyword)

; Modern Concurrency
("async" @keyword)
("await" @keyword)
("actor" @keyword)
("macro" @keyword)

; Types
(type_identifier) @type
(simple_type_identifier) @type
(class_declaration name: (type_identifier) @type)
(struct_declaration name: (type_identifier) @type)
(enum_declaration name: (type_identifier) @type)
(protocol_declaration name: (type_identifier) @type)

; Functions
(function_declaration name: (simple_identifier) @function)
(call_expression (simple_identifier) @function)

; Variables and Properties
(pattern (simple_identifier) @variable)
(property_declaration name: (pattern (simple_identifier) @property))

; Attributes
(attribute "@" @attribute)
(attribute (simple_identifier) @attribute)

; Strings
(line_string_literal) @string
(multi_line_string_literal) @string

; Comments
(comment) @comment

; Numbers
(integer_literal) @number
(real_literal) @number

; Booleans
(boolean_literal) @boolean
