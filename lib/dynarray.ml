type 'a t =
  { count : int
  ; capacity : int
  ; items : 'a list
  }

let init () = { count = 0; capacity = 8; items = [] }
let rev t = { t with items = List.rev t.items }

let get { count; items; _ } idx =
  if idx >= 0 && idx < count
  then (
    match List.drop idx items with
    | item :: _ -> Some item
    | [] -> None)
  else None
;;

let head t = get t 0
let tail t = get t (t.count - 1)

let rec write { count; capacity; items } new_item =
  match capacity < count + 1 with
  | true -> { count = count + 1; capacity = grow_cap capacity; items = new_item :: items }
  | false -> { count = count + 1; capacity; items = new_item :: items }

and grow_cap = function
  | n when n < 8 -> 8
  | n -> n * 2

and nxt_pow_2 n =
  let or_shift x ~by = x lor (x lsr by) in
  let n = n - 1 in
  let n = or_shift n ~by:1 in
  let n = or_shift n ~by:2 in
  let n = or_shift n ~by:4 in
  let n = or_shift n ~by:8 in
  let n = or_shift n ~by:16 in
  let n = n + 1 in
  n
;;
