const std = @import("std");
const Inst = @import("inst.zig").Inst;
const Value = @import("value.zig").Value;

const Self = @This();

pub const STACK_MAX_LENGTH = 256;

program: []Inst,
program_ptr: usize = 0,

stack: [STACK_MAX_LENGTH]Value = .{0} ** STACK_MAX_LENGTH,
stack_ptr: usize = 0,

pub fn run(self: *Self) !void {
    for (self.program) |inst| switch (inst.op) {
        .push => try self.handlePush(inst.val),
        .pop => _ = try self.handlePop(),
        .add => try self.handleMath(add),
        .sub => try self.handleMath(sub),
        .mul => try self.handleMath(mul),
        .div => try self.handleMath(div),
        .mod => try self.handleMath(mod),
        .pow => try self.handleMath(pow),
        .dump => try self.handleDump(),
    };
}

fn handlePush(self: *Self, val: Value) !void {
    if (self.stack_ptr >= STACK_MAX_LENGTH) return error.StackOverflow;
    defer self.stack_ptr += 1;
    self.stack[self.stack_ptr] = val;
}

fn handlePop(self: *Self) !Value {
    if (self.stack_ptr < 0) return error.StackUnderflow;
    self.stack_ptr -= 1;
    defer self.stack[self.stack_ptr] = 0; // TODO: should we zero out?
    return self.stack[self.stack_ptr];
}

fn add(a: Value, b: Value) Value {
    return a + b;
}

fn sub(a: Value, b: Value) Value {
    return a - b;
}

fn mul(a: Value, b: Value) Value {
    return a * b;
}

fn div(a: Value, b: Value) Value {
    return @divExact(a, b);
}

fn mod(a: Value, b: Value) Value {
    return @mod(a, b);
}

fn pow(a: Value, b: Value) Value {
    return std.math.pow(Value, a, b);
}

fn handleMath(self: *Self, f: *const fn (Value, Value) Value) !void {
    const b = try self.handlePop();
    const a = try self.handlePop();
    return self.handlePush(f(a, b));
}

fn handleDump(self: *Self) !void {
    const x = try self.handlePop();
    std.log.info("dump: {}", .{x});
}

pub fn display(self: *Self) void {
    std.log.info("stack: {any}", .{self.stack[0..self.stack_ptr]});
}

pub fn write(self: *Self, w: *std.Io.Writer, comptime vers: []const u8) !usize {
    var wrote: usize = 0;
    wrote += try w.write("ONION " ++ vers);
    for (self.program) |inst| wrote += try w.write(std.mem.asBytes(&inst));
    return wrote;
}
