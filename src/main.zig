const std = @import("std");
const onion = @import("onion");
const Inst = onion.inst.Inst;
const Machine = onion.Machine;

var program = [_]Inst{
    Inst.newVal(.push, 0x1),
    Inst.newVal(.push, 0x2),
    Inst.new(.add),
    Inst.newVal(.push, 0xf),
    Inst.newVal(.push, 0x7),
    Inst.new(.sub),
    Inst.new(.dump),
    Inst.new(.dump),
};

pub fn main() !void {
    const cwd = std.fs.cwd();
    var file = try cwd.createFile("out.onion", .{ .truncate = true, .read = true });
    defer file.close();
    var file_writer = file.writer(&.{});
    const writer = &file_writer.interface;

    var m = Machine{ .program = &program };
    try m.run();
    m.display();
    _ = try m.write(writer, "0.0.1");
}

pub const std_options: std.Options = .{
    .log_level = .info,
    .logFn = onionLog,
};

// TODO: Make more pretty... (and functional)
pub fn onionLog(
    comptime level: std.log.Level,
    comptime scope: @Type(.enum_literal),
    comptime format: []const u8,
    args: anytype,
) void {
    _ = level;
    _ = scope;
    var buffer: [64]u8 = undefined;
    var stderr_writer = std.fs.File.stderr().writer(&buffer);
    const stderr = &stderr_writer.interface;
    stderr.print("== ", .{}) catch return;
    stderr.print(format, args) catch return;
    stderr.print(" ==\n", .{}) catch return;
    stderr.flush() catch return;
}
