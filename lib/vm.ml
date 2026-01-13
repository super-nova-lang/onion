module Ch = Chunk
module Op = Opcode
module Val = Value
module Dyn = Dynarray

exception Stack_overflow
exception Stack_underflow

let ( + ) a b = a + b
let ( +. ) a b = a +. b

type t =
  { chunk : Ch.t
  ; ip : int
  ; stack : Val.t Dyn.t
  ; pp_chunk : Ch.t
  ; pp_stack : Val.t Dyn.t
  }

let init chunk =
  { chunk; ip = 0; stack = Dyn.init (); pp_chunk = chunk; pp_stack = Dyn.init () }
;;

(* Stack functions *)
let stack_push vm v =
  (* Printf.printf "DEBUG: pushing %s\n" (Val.debug v); *)
  { vm with stack = Dyn.write vm.stack v; pp_stack = Dyn.write vm.pp_stack v }
;;

let stack_pop vm =
  match vm.stack.items with
  | head :: tail ->
    let new_stack : Val.t Dyn.t =
      { count = vm.stack.count; capacity = vm.stack.capacity; items = tail }
    in
    Ok ({ vm with stack = new_stack }, head)
  | [] -> Error (vm, "stack underflow")
;;

(* Runner functions *)
let next vm =
  if vm.ip >= List.length (Ch.get_codes vm.chunk)
  then None
  else (
    match Dyn.get (Dyn.rev vm.chunk.codes) vm.ip with
    | Some op -> Some ({ vm with ip = vm.ip + 1 }, op)
    | None -> None)
;;

let rec run vm =
  match next vm with
  | Some (vm, op) ->
    (match op with
     | Op.OpConst -> handle_const vm
     | Op.OpReturn -> handle_return vm
     | Op.OpAdd -> handle_binary vm ~i:( + ) ~f:( +. )
     | Op.OpSub -> handle_binary vm ~i:( - ) ~f:( -. )
     | op -> Error (vm, "unexpected op: " ^ Op.debug op))
  | None -> Ok vm

and handle_const vm =
  match next vm with
  | Some (vm, Op.OpValue idx) ->
    (match Dyn.get vm.chunk.consts idx with
     | Some v -> run (stack_push vm v)
     | None -> Error (vm, "invalid constant index"))
  | Some (_vm, other) -> Error (vm, "unexpected op: " ^ Op.debug other)
  | None -> Error (vm, "unexpected end after OpConstant")

and handle_return vm =
  match stack_pop vm with
  | Ok (vm, v) ->
    print_endline ("Return: " ^ Val.display v);
    run vm
  | Error (vm, e) -> Error (vm, e)

and handle_binary vm ~i ~f =
  match stack_pop vm with
  | Ok (vm, b) ->
    (match stack_pop vm with
     | Ok (vm, a) ->
       (match a, b with
        | Val.ValNumber a, Val.ValNumber b -> run (stack_push vm (Val.ValNumber (i a b)))
        | Val.ValFloat a, Val.ValFloat b -> run (stack_push vm (Val.ValFloat (f a b)))
        | _ -> Error (vm, "here: todo"))
     | Error (vm, e) -> Error (vm, e))
  | Error (vm, e) -> Error (vm, e)
;;

(* Disassembly functions *)
let rec disassemble vm =
  Ch.dissassemble vm.pp_chunk;
  print_endline "";
  disassemble_both vm

and disassemble_both vm =
  print_endline "--------------------+--------------";
  print_endline " constants          | stack        ";
  print_endline "--------------------+--------------";
  print_endline " num | value        | slot | value ";
  print_endline "--------------------+--------------";
  disassemble_both_helper vm 0 (Int.max vm.pp_chunk.consts.count vm.pp_stack.count)

and disassemble_both_helper vm idx max_idx =
  let const_len = vm.pp_chunk.consts.count in
  if idx >= max_idx
  then ()
  else (
    let idx_str = Utils.pad_left (Int.to_string idx) 4 '0' in
    let val_str =
      if idx >= const_len
      then Utils.pad_right "" 12 ' '
      else (
        match Dyn.get vm.pp_chunk.consts idx with
        | Some v -> Utils.pad_right (Val.debug v) 0 ' '
        | None -> failwith "const idx out of bounds")
    in
    Printf.printf "%s | %s |" idx_str val_str;
    match Dyn.get vm.pp_stack idx with
    | Some v ->
      let val_str = Utils.pad_right (Val.display v) 8 ' ' in
      Printf.printf " %s | %s\n" idx_str val_str;
      disassemble_both_helper vm (idx + 1) max_idx
    | None -> print_endline "")
;;
