type t =
  (* Keywords *)
  | Constant
  | Print
  (* Literals *)
  | Ident of string
  | String of string
  | Comment of string
  | Number of int
  | Float of float
  | Eof

let debug = function
  | Constant -> "Constant"
  | Print -> "Print"
  | Ident s -> "Ident(" ^ s ^ ")"
  | String s -> "String(" ^ s ^ ")"
  | Comment _ -> "Comment(...)"
  | Number n -> "Number(" ^ Int.to_string n ^ ")"
  | Float f -> "Float(" ^ Float.to_string f ^ ")"
  | Eof -> "Eof"
;;
