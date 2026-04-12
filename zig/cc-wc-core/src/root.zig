const flags = @import("flags.zig");
const arguments = @import("arguments.zig");
const counter = @import("counter.zig");
pub const runner = @import("runner.zig");

test {
    @import("std").testing.refAllDeclsRecursive(@This());
}
