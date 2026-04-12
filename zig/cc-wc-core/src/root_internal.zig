pub const flags = @import("flags.zig");
pub const arguments = @import("arguments.zig");
pub const counting = @import("counting.zig");
pub const execution = @import("execution.zig");

test {
    @import("std").testing.refAllDeclsRecursive(@This());
}
