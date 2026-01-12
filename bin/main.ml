module O = Onion
module Lexer = O.Lexer
module Token = O.Token

(* let lexer = L.init *)

(* List.filter (fn t -> match t with  *)
(*   | Token.Comment _ -> False  *)
(*   | _ -> True) *)
(**)

let read_file file =
  try In_channel.with_open_text file In_channel.input_all with
  | Sys_error msg -> failwith ("Failed to read file: " ^ msg)
;;

let filter_comment = function
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
  Lexer.collect Lexer.init filepath source []
  |> List.filter filter_comment
  |> List.map (fun (l, t) -> Lexer.pp_loc l ^ ": " ^ Token.debug t)
  |> List.iter print_endline
;;
