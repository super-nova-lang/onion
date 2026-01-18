import gleam/int
import onion/lexer.{type OpCode} as op

pub type Vm {
  Vm(
    // Code
    code: List(OpCode),
    // Stack
    stack: List(Int),
    // Registers
    regs: List(Int),
  )
}

pub fn new(code: List(OpCode)) -> Vm {
  Vm(code, [], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
}

fn advance(vm: Vm, rest: List(OpCode)) -> Vm {
  Vm(..vm, code: rest)
}

fn push(vm: Vm, val: Int) -> Vm {
  Vm(..vm, stack: [val, ..vm.stack])
}

fn pop_stack(vm: Vm) -> #(Vm, Int) {
  case vm.stack {
    [] -> panic as { "stack underflow" }
    [head, ..tail] -> #(Vm(..vm, stack: tail), head)
  }
}

fn pop_to_register(vm: Vm, reg: Int) -> Vm {
  case reg {
    x if x <= 9 -> {
      let #(vm, x) = pop_stack(vm)
      let vm = vm.regs[reg] = x
      todo
    }
    x -> panic as { "invalid register" <> int.to_string(x) }
  }
}

fn binop(vm: Vm, f: fn(Int, Int) -> Int) -> Vm {
  let #(vm, b) = pop_stack(vm)
  let #(vm, a) = pop_stack(vm)
  push(vm, f(a, b))
}

pub fn run(vm: Vm) -> Result(Vm, #(Vm, String)) {
  case vm.code {
    [op.Push, op.NumberLit(n), ..tail] -> run(advance(push(vm, n), tail))
    [op.Pop, op.Register, op.NumberLit(reg), ..tail] ->
      run(advance(pop_to_register(vm, reg), tail))
    [op.Add, ..tail] -> run(advance(binop(vm, fn(a, b) { a + b }), tail))
    [] -> Ok(vm)
    _ -> Error(#(vm, "Unknown"))
  }
}
