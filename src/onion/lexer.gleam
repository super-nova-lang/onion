import gleam/int
import gleam/list
import gleam/string

pub type OpCode {
  // Stack Manipulation
  Push
  Pop
  // Register Manipulation
  Set
  // Math
  Add
  Sub
  Mul
  Div
  Mod
  Pow
  // Other
  Call
  Register
  // Literals
  NumberLit(Int)
  FloatLit(Float)
  // Eof
  Eof
}

pub fn lex(str: String, list: List(OpCode)) -> List(OpCode) {
  let tokens =
    str
    |> string.split(" ")
    |> list.flat_map(with: fn(s) { string.split(s, "\n") })
    |> list.flat_map(with: fn(s) { string.split(s, "\t") })
    |> list.filter(fn(x) { x != "" })

  loop(tokens, list)
}

fn loop(tokens: List(String), acc: List(OpCode)) -> List(OpCode) {
  case tokens {
    [] -> list.reverse(acc)
    [head, ..tail] ->
      case head {
        "!-" -> {
          let rest = list.drop_while(tail, fn(t) { t != "-!" })
          loop(rest, acc)
        }
        "push" -> loop(tail, [Push, ..acc])
        "pop" -> loop(tail, [Pop, ..acc])
        "set" -> loop(tail, [Set, ..acc])
        "add" -> loop(tail, [Add, ..acc])
        "sub" -> loop(tail, [Sub, ..acc])
        "mul" -> loop(tail, [Mul, ..acc])
        "div" -> loop(tail, [Div, ..acc])
        "mod" -> loop(tail, [Mod, ..acc])
        "pow" -> loop(tail, [Pow, ..acc])
        "call" -> loop(tail, [Call, ..acc])
        "reg" -> loop(tail, [Register, ..acc])
        _ ->
          case int.parse(head) {
            Ok(i) -> loop(tail, [NumberLit(i), ..acc])
            _ -> loop(tail, acc)
          }
      }
  }
}
