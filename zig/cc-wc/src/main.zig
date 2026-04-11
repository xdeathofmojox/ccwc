const std = @import("std");
const hello = @import("cc-wc-core").hello;

// TODO: Implement cc-wc executable in Zig
pub fn main() void {
    std.debug.print("{s}\n", .{hello});
}
