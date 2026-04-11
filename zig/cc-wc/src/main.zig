const std = @import("std");
const cc_wc_core = @import("cc-wc-core");

// TODO: Implement cc-wc executable in Zig
pub fn main() void {
    std.debug.print("{s}\n", .{cc_wc_core.hello});
    std.debug.print("Flag enum values:\n", .{});
    std.debug.print("- bytes: {d}\n", .{cc_wc_core.Flag.bytes});
    std.debug.print("- lines: {d}\n", .{cc_wc_core.Flag.lines});
    std.debug.print("- words: {d}\n", .{cc_wc_core.Flag.words});
    std.debug.print("- characters: {d}\n", .{cc_wc_core.Flag.characters});
}
