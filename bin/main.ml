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

let () =
  let filepath =
    match Sys.argv with
    | [| _; file |] -> file
    | args ->
      failwith ("got " ^ Int.to_string (Array.length args - 1) ^ " args, expected 1")
  in
  let source = read_file filepath in
  Lexer.collect Lexer.init filepath source []
  |> Chunk.start
  |> Chunk.chunker 0
  |> Chunk.finish
  |> Vm.init
  |> Vm.run
  |> Vm.disassemble
;;
