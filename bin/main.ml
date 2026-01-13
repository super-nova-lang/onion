[@@@ocaml.warning "-32-26"]

module O = Onion
module Lexer = O.Lexer
module Token = O.Token
module Chunk = O.Chunk
module Vm = O.Vm
module V = O.Value

let read_file file =
  try In_channel.with_open_text file In_channel.input_all with
  | Sys_error msg -> failwith ("Failed to read file: " ^ msg)
;;

let rec filter_comments t = List.filter filter_comments_helper t

and filter_comments_helper = function
  | _, Token.Comment _ -> false
  | _ -> true
;;

let () =
  let filepath =
    match Sys.argv with
    | [| _; file |] -> file
    | args -> failwith ("got " ^ Int.to_string (Array.length args) ^ " args, expected 2")
  in
  let source = read_file filepath in
  match
    Lexer.collect Lexer.init filepath source []
    |> filter_comments
    |> Chunk.start
    |> Chunk.chunker 0
    |> Chunk.finish
    |> Vm.init
    |> Vm.run
  with
  | Ok vm -> Vm.disassemble vm
  | Error (vm, e) ->
    Vm.disassemble vm;
    failwith e
;;
