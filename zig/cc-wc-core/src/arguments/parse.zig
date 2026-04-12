const std = @import("std");
const Flag = @import("cc-wc-core-internal").flags.Flag;
const FlagSet = @import("cc-wc-core-internal").flags.FlagSet;
const Args = @import("cc-wc-core-internal").arguments.Args;

pub fn parseFlagsAndFilenames(args: []const []const u8) error{IllegalOption}!Args {
    var first_file: usize = args.len;
    for (args, 0..) |arg, i| {
        if (arg.len == 0 or arg[0] != '-') {
            first_file = i;
            break;
        }
    }

    const flag_args = args[0..first_file];
    const files = args[first_file..];

    var flags = FlagSet.initEmpty();
    for (flag_args) |arg| {
        try parseFlag(arg, &flags);
    }

    if (flags.count() == 0) {
        flags.insert(.bytes);
        flags.insert(.lines);
        flags.insert(.words);
    }

    return .{ .flags = flags, .files = files };
}

fn parseFlag(arg: []const u8, flags: *FlagSet) error{IllegalOption}!void {
    if (arg.len < 2) return;
    for (arg[1..]) |c| {
        switch (c) {
            'c' => {
                flags.remove(.characters);
                flags.insert(.bytes);
            },
            'l' => flags.insert(.lines),
            'w' => flags.insert(.words),
            'm' => {
                flags.remove(.bytes);
                flags.insert(.characters);
            },
            else => {
                var buf: [64]u8 = undefined;
                var w = std.fs.File.Writer.initStreaming(std.fs.File.stderr(), &buf);
                w.interface.print("ccwc: illegal option -- {c}\n", .{c}) catch {};
                w.interface.flush() catch {};
                return error.IllegalOption;
            },
        }
    }
}

test "empty args returns default flags" {
    const result = try parseFlagsAndFilenames(&.{});
    try std.testing.expect(result.flags.contains(.bytes));
    try std.testing.expect(result.flags.contains(.lines));
    try std.testing.expect(result.flags.contains(.words));
    try std.testing.expect(!result.flags.contains(.characters));
    try std.testing.expectEqual(@as(usize, 0), result.files.len);
}

test "explicit flags override defaults" {
    const args: []const []const u8 = &.{"-l"};
    const result = try parseFlagsAndFilenames(args);
    try std.testing.expect(result.flags.contains(.lines));
    try std.testing.expect(!result.flags.contains(.bytes));
    try std.testing.expect(!result.flags.contains(.words));
    try std.testing.expect(!result.flags.contains(.characters));
}

test "m flag replaces c flag" {
    const args: []const []const u8 = &.{ "-c", "-m" };
    const result = try parseFlagsAndFilenames(args);
    try std.testing.expect(result.flags.contains(.characters));
    try std.testing.expect(!result.flags.contains(.bytes));
    try std.testing.expect(!result.flags.contains(.lines));
    try std.testing.expect(!result.flags.contains(.words));
}

test "c flag replaces m flag" {
    const args: []const []const u8 = &.{ "-m", "-c" };
    const result = try parseFlagsAndFilenames(args);
    try std.testing.expect(result.flags.contains(.bytes));
    try std.testing.expect(!result.flags.contains(.characters));
    try std.testing.expect(!result.flags.contains(.lines));
    try std.testing.expect(!result.flags.contains(.words));
}

test "files collected after flags" {
    const args: []const []const u8 = &.{ "-l", "a.txt", "b.txt" };
    const result = try parseFlagsAndFilenames(args);
    try std.testing.expectEqual(@as(usize, 2), result.files.len);
    try std.testing.expectEqualStrings("a.txt", result.files[0]);
    try std.testing.expectEqualStrings("b.txt", result.files[1]);
}

test "illegal flag returns error" {
    const args: []const []const u8 = &.{"-z"};
    try std.testing.expectError(error.IllegalOption, parseFlagsAndFilenames(args));
}
