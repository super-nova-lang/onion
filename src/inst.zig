const Value = @import("value.zig").Value;

pub const OpCode = enum(u8) {
    // Stack
    push,
    pop,
    // Math
    add,
    sub,
    mul,
    div,
    mod,
    pow,
    // Syscalls
    dump,
};

pub const Inst = packed struct {
    op: OpCode,
    val: Value = 0,

    pub fn new(op: OpCode) Inst {
        return .{ .op = op };
    }

    pub fn newVal(op: OpCode, v: Value) Inst {
        return .{ .op = op, .val = v };
    }
};
