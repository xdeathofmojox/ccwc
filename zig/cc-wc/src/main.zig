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

    var flags = std.AutoHashMap(cc_wc_core.Flag, void).init(allocator);
    defer flags.deinit();
    // The first argument is usually the executable path
    while (iter.next()) |arg| {
        std.debug.print("Arg: {s}\n", .{arg});
        if (std.mem.eql(u8, arg, "-c")) {
            try flags.put(cc_wc_core.Flag.characters, {});
            std.debug.print("Flag set: characters\n", .{});
        }
    }
}