module Dyn = Dynarray

type t =
  { codes : Opcode.t Dyn.t
  ; lines : Lexer.loc Dyn.t
  ; consts : Value.t Dyn.t
  }

(* Const functions *)
let get_consts t = List.rev t.consts.items

let write_const t value idx loc =
  { consts = Dyn.write t.consts value
  ; codes = Dyn.write t.codes (Opcode.OpValue idx)
  ; lines = Dyn.write t.lines loc
  }
;;

let write_const_list t values idxs locs =
  List.fold_right
    (fun (c, idx, l) t -> write_const t c idx l)
    (Utils.combine_3 values idxs locs)
    t
;;

(* Code functions *)

let get_codes t = List.rev t.codes.items

let write_code t value loc =
  { t with codes = Dyn.write t.codes value; lines = Dyn.write t.lines loc }
;;

let write_code_list t values locs =
  List.fold_right (fun (c, l) t -> write_code t c l) (List.combine values locs) t
;;

(* Line functions *)
let get_lines t = List.rev t.lines.items

(* Dissassembly *)
let rec dissassemble t =
  print_endline "-----+------+------------+--------------";
  print_endline "addr | line | opcode     | operand      ";
  print_endline "-----+------+------------+--------------";
  dissassemble_inst t (get_codes t) (get_lines t) 0 (-1);
  print_endline "-----+------+------------+--------------"

and dissassemble_inst t codes lines offset prev =
  match codes, lines with
  | x :: xs, ln :: ls ->
    let line_str = if ln.row == prev then "-" else Int.to_string ln.row in
    let op_name = Opcode.debug x in
    let operand = Opcode.operand x in
    (* <addr> | <line> | <opcode> | <operand> *)
    let addr_str = Utils.pad_left (Int.to_string offset) 4 '0' in
    let line_str = Utils.pad_left line_str 4 ' ' in
    let op_str = Utils.pad_right op_name 10 ' ' in
    let operand_str = operand in
    Printf.printf "%s | %s | %s | %s\n" addr_str line_str op_str operand_str;
    dissassemble_inst t xs ls (offset + 1) ln.row
  | [], [] -> ()
  | _ -> failwith "unreachable: dissassemble_inst"
;;

module Chunker = struct
  open Token
  open Opcode
  open Value

  let rec from_tokens chunk idx = function
    | (loc, tok) :: tail ->
      (match tok with
       (* Keywords *)
       | Constant -> from_tokens (write_code chunk OpConst loc) idx tail
       | Return -> from_tokens (write_code chunk OpReturn loc) idx tail
       | Add -> from_tokens (write_code chunk OpAdd loc) idx tail
       | Sub -> from_tokens (write_code chunk OpSub loc) idx tail
       (* Literals *)
       | Number n -> from_tokens (write_const chunk (ValNumber n) idx loc) (idx + 1) tail
       | _ -> failwith (Lexer.pp_loc loc ^ ": unreachable in Chunk.from_tokens"))
    | [] -> chunk
  ;;
end

(* Init functions*)
let init () = { codes = Dyn.init (); lines = Dyn.init (); consts = Dyn.init () }
let start tokens = tokens
let chunker tokens = Chunker.from_tokens (init ()) tokens
let finish t = { codes = t.codes; lines = t.lines; consts = Dyn.rev t.consts }
