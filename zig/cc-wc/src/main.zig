const std = @import("std");
const cc_wc_core = @import("cc-wc-core");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = std.process.argsAlloc(allocator) catch std.process.exit(1);
    defer std.process.argsFree(allocator, args);

    const exit_code = cc_wc_core.runner.run(allocator, args[1..]);
    std.process.exit(exit_code);
}
