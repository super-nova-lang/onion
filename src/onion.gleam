import simplifile as sf

import onion/lexer
import onion/vm

pub fn main() -> Nil {
  let source = case sf.read("./examples/math.onion") {
    Ok(s) -> s
    Error(_) -> panic as { "could not read file" }
  }
  let tokens = lexer.lex(source, [])
  let vm = vm.new(tokens)
  case vm.run(vm) {
    Ok(vm) -> echo #(vm, "")
    Error(e) -> echo e
  }
  Nil
}
