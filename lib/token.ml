type t =
  (* Keywords *)
  | Constant
  | Return
  | Add
  | Sub
  | Mul
  | Div
  (* Literals *)
  | Ident of string
  | String of string
  | Comment of string
  | Number of int
  | Float of float
  | Eof
