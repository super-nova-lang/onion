module P = Printf

type t =
  | ValNumber of int
  | ValFloat of float
  | ValBool of bool
  | ValNil

let debug = function
  | ValNumber n -> P.sprintf "ValNumber(%X)" n
  | ValFloat f -> P.sprintf "ValFloat(%g)" f
  | ValBool b -> "ValBool(" ^ Bool.to_string b ^ ")"
  | ValNil -> "ValNil"
;;

let display = function
  | ValNumber n -> P.sprintf "0x%X" n
  | ValFloat f -> P.sprintf "%g" f
  | ValBool b -> Bool.to_string b
  | ValNil -> "nil"
;;
