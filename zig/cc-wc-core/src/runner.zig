const std = @import("std");
const arguments = @import("cc-wc-core-internal").arguments;
const counter = @import("cc-wc-core-internal").counter;
const FlagSet = @import("cc-wc-core-internal").flags.FlagSet;

pub fn run(allocator: std.mem.Allocator, args: []const []const u8) u8 {
    const parsed = arguments.parseFlagsAndFilenames(args) catch return 1;

    if (parsed.files.len == 0) {
        return processStdin(allocator, parsed.flags);
    }
    return processFiles(allocator, parsed.flags, parsed.files);
}

fn processStdin(allocator: std.mem.Allocator, flags: FlagSet) u8 {
    const counts = counter.count(allocator, std.fs.File.stdin().deprecatedReader(), flags) catch return 1;
    counter.printCounts(flags, counts);
    std.fs.File.stdout().deprecatedWriter().print("\n", .{}) catch {};
    return 0;
}

fn processFiles(allocator: std.mem.Allocator, flags: FlagSet, filepaths: []const []const u8) u8 {
    var status: u8 = 0;
    for (filepaths) |filepath| {
        processFile(allocator, flags, filepath, &status);
    }
    return status;
}

fn processFile(allocator: std.mem.Allocator, flags: FlagSet, filepath: []const u8, status: *u8) void {
    const file = std.fs.cwd().openFile(filepath, .{}) catch {
        std.fs.File.stderr().deprecatedWriter().print("ccwc: {s}: No such file or directory\n", .{filepath}) catch {};
        status.* = 1;
        return;
    };
    defer file.close();

    const counts = counter.count(allocator, file.deprecatedReader(), flags) catch {
        status.* = 1;
        return;
    };
    counter.printCounts(flags, counts);
    std.fs.File.stdout().deprecatedWriter().print(" {s}\n", .{filepath}) catch {};
}
