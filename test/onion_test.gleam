import gleeunit
import onion/lexer as ol
import simplifile as sf

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn lexer_test() {
  let source = case sf.read("./examples/math.onion") {
    Ok(s) -> s
    Error(_) -> panic as { "could not read file" }
  }
  assert ol.lex(source, [])
    == [
      ol.Set,
      ol.Register,
      ol.NumberLit(0),
      ol.NumberLit(1),
      ol.Set,
      ol.Register,
      ol.NumberLit(1),
      ol.NumberLit(1),
      ol.Push,
      ol.NumberLit(1),
      ol.Push,
      ol.NumberLit(2),
      ol.Add,
      ol.Pop,
      ol.Register,
      ol.NumberLit(3),
      ol.Call,
      ol.Set,
      ol.Register,
      ol.NumberLit(3),
      ol.NumberLit(0),
    ]
}
