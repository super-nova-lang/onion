module P = Printf

type t =
  | OpConst
  | OpReturn
  | OpTrue
  | OpFalse
  | OpAdd
  | OpSub
  | OpMul
  | OpDiv
  | OpValue of int

let debug = function
  | OpConst -> "OpConst"
  | OpReturn -> "OpReturn"
  | OpTrue -> "OpTrue"
  | OpFalse -> "OpFalse"
  | OpAdd -> "OpAdd"
  | OpSub -> "OpSub"
  | OpMul -> "OpMul"
  | OpDiv -> "OpDiv"
  | OpValue _ -> "OpValue"
;;

let operand = function
  | OpValue v -> P.sprintf "0x%X" v
  | _ -> ""
;;
