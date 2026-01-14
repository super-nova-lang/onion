module Dyn = Dynarray

type t =
  { codes : Opcode.t Dyn.t
  ; lines : Lexer.loc Dyn.t
  ; consts : Value.t Dyn.t
  ; comments : string option Dyn.t
  }

(* Const functions *)
let get_consts t = List.rev t.consts.items

let write_const t value idx loc =
  { consts = Dyn.write t.consts value
  ; codes = Dyn.write t.codes (Opcode.OpValue idx)
  ; lines = Dyn.write t.lines loc
  ; comments = Dyn.write t.comments None
  }
;;

(* Comment functions *)
let get_comments t = List.rev t.comments.items

let write_comment t loc comment =
  { t with comments = Dyn.write t.comments (Some comment); lines = Dyn.write t.lines loc }
;;

(* Code functions *)

let get_codes t = List.rev t.codes.items

let write_code t value loc =
  { t with
    codes = Dyn.write t.codes value
  ; lines = Dyn.write t.lines loc
  ; comments = Dyn.write t.comments None
  }
;;

(* Line functions *)
let get_lines t = List.rev t.lines.items

(* Dissassembly *)
let rec dissassemble t =
  print_endline "-----+------+------------+---------------+-----------";
  print_endline "addr | line | opcode     | operand (idx) | comments  ";
  print_endline "-----+------+------------+---------------+-----------";
  dissassemble_inst t (get_codes t) (get_lines t) (get_comments t) 0 (-1);
  print_endline "-----+------+------------+---------------+-----------"

and dissassemble_inst t _codes lines comments offset prev =
  (* Use lines/comments as the authoritative sequence; where comments[i] = None it's a code and we consume from codes list *)
  let codes = get_codes t in
  let lines = lines in
  let comments = comments in
  let rec loop i code_idx offset prev =
    if i >= List.length lines
    then ()
    else (
      let ln = List.nth lines i in
      let cn = List.nth comments i in
      let line_str = if ln.row = prev then "|" else Int.to_string ln.row in
      let len = List.length comments in
      if cn = None
      then (
        (* This slot corresponds to a code. Check if the next slot is an inline comment on the same line *)
        let x = List.nth codes code_idx in
        let inline_comment =
          if i + 1 < len
          then (
            match List.nth comments (i + 1) with
            | Some msg ->
              let next_ln = List.nth lines (i + 1) in
              if next_ln.row = ln.row then Some msg else None
            | None -> None)
          else None
        in
        let addr_str = Utils.pad_left (Int.to_string offset) 4 '0' in
        let op_str = Utils.pad_right (Opcode.debug x) 10 ' ' in
        let operand_str = Utils.pad_right (Opcode.operand x) 13 ' ' in
        let line_str = Utils.pad_left line_str 4 ' ' in
        let comment_str =
          match inline_comment with
          | Some msg -> Utils.pad_right msg 12 ' '
          | None -> Utils.pad_right "" 12 ' '
        in
        Printf.printf
          "%s | %s | %s | %s | %s\n"
          addr_str
          line_str
          op_str
          operand_str
          comment_str;
        let next_prev = ln.row in
        let consumed = if inline_comment = None then 1 else 2 in
        loop (i + consumed) (code_idx + 1) (offset + 1) next_prev)
      else (
        (* Comment-only slot *)
        let addr_str = Utils.pad_left "" 4 ' ' in
        let op_str = Utils.pad_right "" 10 ' ' in
        let operand_str = Utils.pad_right "" 13 ' ' in
        let line_str = Utils.pad_left line_str 4 ' ' in
        let comment_str =
          match cn with
          | Some msg -> Utils.pad_right msg 12 ' '
          | None -> Utils.pad_right "" 12 ' '
        in
        Printf.printf
          "%s | %s | %s | %s | %s\n"
          addr_str
          line_str
          op_str
          operand_str
          comment_str;
        let next_prev = ln.row in
        loop (i + 1) code_idx offset next_prev))
  in
  loop 0 0 offset prev
;;

module Chunker = struct
  open Token
  open Opcode
  open Value

  let write_code2 c1 c2 op loc = write_code c1 op loc, write_code c2 op loc
  let write_const2 c1 c2 op idx loc = write_const c1 op idx loc, write_const c2 op idx loc

  let rec from_tokens (chunk, pp_chunk) const_idx = function
    | (loc, tok) :: tail ->
      (match tok with
       (* Keywords *)
       | Constant -> from_tokens (write_code2 chunk pp_chunk OpConst loc) const_idx tail
       | Return -> from_tokens (write_code2 chunk pp_chunk OpReturn loc) const_idx tail
       | Add -> from_tokens (write_code2 chunk pp_chunk OpAdd loc) const_idx tail
       | Sub -> from_tokens (write_code2 chunk pp_chunk OpSub loc) const_idx tail
       (* Literals *)
       | Number n ->
         from_tokens
           (write_const2 chunk pp_chunk (ValNumber n) const_idx loc)
           (const_idx + 1)
           tail
       | Float f ->
         from_tokens
           (write_const2 chunk pp_chunk (ValFloat f) const_idx loc)
           (const_idx + 1)
           tail
       | Comment msg -> from_tokens (chunk, write_comment pp_chunk loc msg) const_idx tail
       | _ -> failwith (Lexer.pp_loc loc ^ ": unreachable in Chunk.from_tokens"))
    | [] -> chunk, pp_chunk
  ;;
end

(* Init functions*)
let init () =
  { codes = Dyn.init ()
  ; lines = Dyn.init ()
  ; consts = Dyn.init ()
  ; comments = Dyn.init ()
  }
;;

let start tokens = tokens
let chunker tokens = Chunker.from_tokens (init (), init ()) tokens

let finish (t1, t2) =
  { t1 with consts = Dyn.rev t1.consts }, { t2 with consts = Dyn.rev t2.consts }
;;
