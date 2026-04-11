const std = @import("std");
const cc_wc_core = @import("cc-wc-core");

// TODO: Implement cc-wc executable in Zig
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Use an iterator for memory efficiency
    var iter = try std.process.argsWithAllocator(allocator);
    defer iter.deinit();

    // The first argument is usually the executable path
    while (iter.next()) |arg| {
        std.debug.print("Arg: {s}\n", .{arg});
    }

    std.debug.print("{s}\n", .{cc_wc_core.hello});
    std.debug.print("Flag enum values:\n", .{});
    std.debug.print("- bytes: {d}\n", .{cc_wc_core.Flag.bytes});
    std.debug.print("- lines: {d}\n", .{cc_wc_core.Flag.lines});
    std.debug.print("- words: {d}\n", .{cc_wc_core.Flag.words});
    std.debug.print("- characters: {d}\n", .{cc_wc_core.Flag.characters});
}