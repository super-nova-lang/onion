module U = Utils

exception Todo
exception LexerError of string

type t =
  { checks : (Re.re * (string -> Token.t)) list
  ; eof : Token.t
  }

and loc =
  { path : string
  ; row : int
  ; col : int
  }

let pp_loc { path; row; col } = path ^ ":" ^ Int.to_string row ^ ":" ^ Int.to_string col

let init =
  let checks =
    [ U.re_pair {|^;;.*|} (fun x ->
        Token.Comment
          (if String.length x >= 2 then String.sub x 2 (String.length x - 2) else ""))
    ; U.re_pair {|^constant\b|} (fun _ -> Token.Constant)
    ; U.re_pair {|^return\b|} (fun _ -> Token.Return)
    ; U.re_pair {|^add\b|} (fun _ -> Token.Add)
    ; U.re_pair {|^sub\b|} (fun _ -> Token.Sub)
    ; U.re_pair {|^"([^"\\]|\\.)*"|} (fun x ->
        Token.String (String.sub x 1 (String.length x - 2)))
    ; U.re_pair {|^-?[0-9]+\.[0-9]*|} (fun x -> Token.Float (float_of_string x))
    ; U.re_pair {|^0x[0-9A-Fa-f]+|} (fun x -> Token.Number (int_of_string x))
    ; U.re_pair {|^-?[0-9]+|} (fun x -> Token.Number (int_of_string x))
    ; U.re_pair {|^[a-zA-Z][a-zA-Z0-9_]*|} (fun x -> Token.Ident x)
    ]
  in
  { checks; eof = Token.Eof }
;;

let skip_whitespace source =
  let len = String.length source in
  let rec find i =
    if i >= len
    then i
    else (
      match source.[i] with
      | ' ' | '\n' | '\t' | '\r' -> find (i + 1)
      | _ -> i)
  in
  let i = find 0 in
  if i >= len then "", i else String.sub source i (len - i), i
;;

let rec collect_helper lexer filepath source acc row col =
  let source', skipped = skip_whitespace source in
  let skipped_str = if skipped > 0 then String.sub source 0 skipped else "" in
  let count_newlines s =
    let len = String.length s in
    let rec loop i cnt last =
      if i >= len
      then cnt, last
      else if s.[i] = '\n'
      then loop (i + 1) (cnt + 1) i
      else loop (i + 1) cnt last
    in
    loop 0 0 (-1)
  in
  let nl_count, last_nl_pos = count_newlines skipped_str in
  let row_after_ws = row + nl_count in
  let col_after_ws = if nl_count = 0 then col + skipped else skipped - last_nl_pos - 1 in
  if source' = ""
  then acc
  else (
    let source_len = String.length source' in
    let rec try_checks = function
      | [] -> acc
      | (fn, con) :: tail ->
        (match Re.exec_opt fn source' with
         | Some group ->
           let str = Re.Group.get group 0 in
           let len = String.length str in
           let token = con str in
           let loc = { path = filepath; row = row_after_ws; col = col_after_ws } in
           let tok_nl_count, tok_last_nl_pos = count_newlines str in
           let next_row, next_col =
             if tok_nl_count = 0
             then row_after_ws, col_after_ws + len
             else row_after_ws + tok_nl_count, len - tok_last_nl_pos - 1
           in
           let remaining =
             if source_len - len <= 0
             then ""
             else String.sub source' len (source_len - len)
           in
           collect_helper lexer filepath remaining ((loc, token) :: acc) next_row next_col
         | None -> try_checks tail)
    in
    try_checks lexer.checks)
;;

let collect lexer filepath source acc =
  collect_helper lexer filepath source acc 1 0 |> List.rev
;;

let rec next_helper { checks; eof } source =
  let source_len = String.length source in
  match checks with
  | [] -> None
  | (fn, con) :: tail ->
    (match Re.exec_opt fn source with
     | Some group ->
       let str = Re.Group.get group 0 in
       let len = String.length str in
       let token = con str in
       Some (String.sub source len (source_len - len), token)
     | None -> next_helper { checks = tail; eof } source)
;;

let next_safe { checks; eof } source =
  let source', _ = skip_whitespace source in
  match next_helper { checks; eof } source' with
  | Some (s, t) -> Some (s, t)
  | None -> Some ("", eof)
;;

let next lexer source =
  match next_safe lexer source with
  | Some (s, t) -> s, t
  | None -> raise (LexerError ("could not lex " ^ source))
;;
