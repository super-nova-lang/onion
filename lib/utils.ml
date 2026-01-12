let re = Re.Perl.re
let re_pair s t = re s |> Re.compile, t
let string_explode s = s |> String.to_seq |> List.of_seq
let string_implode char_list = char_list |> List.to_seq |> String.of_seq
