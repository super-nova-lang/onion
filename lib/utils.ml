(* General helpers *)
let todo ~msg = failwith ("todo: " ^ msg)

(* Regex helpers *)
let re = Re.Perl.re
let re_pair s t = re s |> Re.compile, t

(* String helpers *)
let string_explode s = s |> String.to_seq |> List.of_seq
let string_implode char_list = char_list |> List.to_seq |> String.of_seq

let pad_left s width pad_char =
  let len = String.length s in
  if len >= width
  then s
  else (
    let padding_len = width - len in
    let padding = String.make padding_len pad_char in
    padding ^ s)
;;

let pad_right s width pad_char =
  let len = String.length s in
  if len >= width
  then s
  else (
    let padding_len = width - len in
    let padding = String.make padding_len pad_char in
    s ^ padding)
;;

(* List helpers *)

let rec combine_3 l1 l2 l3 =
  match l1, l2, l3 with
  | [], [], [] -> []
  | h1 :: t1, h2 :: t2, h3 :: t3 -> (h1, h2, h3) :: combine_3 t1 t2 t3
  | _ -> invalid_arg "combine_lists: Lists must have the same length"
;;
