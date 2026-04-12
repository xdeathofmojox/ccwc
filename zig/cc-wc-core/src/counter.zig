const std = @import("std");
const Flag = @import("cc-wc-core-internal").flags.Flag;
const FlagSet = @import("cc-wc-core-internal").flags.FlagSet;

pub const Counts = struct {
    bytes: usize = 0,
    lines: usize = 0,
    words: usize = 0,
    chars: usize = 0,
};

pub fn count(reader: *std.Io.Reader, flags: FlagSet) !Counts {
    if (flags.count() == 1 and flags.contains(.bytes)) {
        return countBytesOnly(reader);
    }
    return countWithLines(reader, flags);
}

fn countBytesOnly(reader: *std.Io.Reader) !Counts {
    return .{ .bytes = try reader.discard(.unlimited) };
}

fn countWithLines(reader: *std.Io.Reader, flags: FlagSet) !Counts {
    const active = ActiveFlags.fromFlags(flags);
    var counts = Counts{};

    while (true) {
        const line_with_nl = reader.takeDelimiterInclusive('\n') catch |err| switch (err) {
            error.EndOfStream => {
                const remaining = reader.buffered();
                if (remaining.len > 0) processLine(remaining, false, &counts, &active);
                break;
            },
            error.ReadFailed => return error.ReadFailed,
            error.StreamTooLong => return error.StreamTooLong,
        };
        processLine(line_with_nl[0 .. line_with_nl.len - 1], true, &counts, &active);
    }

    return counts;
}

fn processLine(line: []const u8, had_newline: bool, counts: *Counts, active: *const ActiveFlags) void {
    if (active.bytes) {
        counts.bytes += line.len;
        if (had_newline) counts.bytes += 1;
    }
    if (active.lines) {
        counts.lines += 1;
    }
    if (active.words) {
        var iter = std.mem.tokenizeAny(u8, line, " \t\r\x0b\x0c");
        while (iter.next()) |_| counts.words += 1;
    }
    if (active.chars) {
        const view = std.unicode.Utf8View.init(line) catch {
            counts.chars += line.len;
            if (had_newline) counts.chars += 1;
            return;
        };
        var char_iter = view.iterator();
        while (char_iter.nextCodepoint()) |_| counts.chars += 1;
        if (had_newline) counts.chars += 1;
    }
}

pub fn printCounts(flags: FlagSet, counts: Counts, writer: *std.Io.Writer) void {
    if (flags.contains(.lines)) writer.print(" {d:>7}", .{counts.lines}) catch {};
    if (flags.contains(.words)) writer.print(" {d:>7}", .{counts.words}) catch {};
    if (flags.contains(.bytes)) writer.print(" {d:>7}", .{counts.bytes}) catch {};
    if (flags.contains(.characters)) writer.print(" {d:>7}", .{counts.chars}) catch {};
}

const ActiveFlags = struct {
    bytes: bool,
    lines: bool,
    words: bool,
    chars: bool,

    fn fromFlags(flags: FlagSet) ActiveFlags {
        return .{
            .bytes = flags.contains(.bytes),
            .lines = flags.contains(.lines),
            .words = flags.contains(.words),
            .chars = flags.contains(.characters),
        };
    }
};

const arguments = @import("arguments.zig");

fn countStr(allocator: std.mem.Allocator, input: []const u8, flag_str: []const u8) !Counts {
    var args_list = std.ArrayList([]const u8){};
    defer args_list.deinit(allocator);
    var iter = std.mem.tokenizeAny(u8, flag_str, " \t");
    while (iter.next()) |token| try args_list.append(allocator, token);
    const result = try arguments.parseFlagsAndFilenames(args_list.items);
    var fbs = std.io.fixedBufferStream(input);
    var gen_reader = fbs.reader();
    var adapt_buf: [4096]u8 = undefined;
    var adapted = gen_reader.adaptToNewApi(&adapt_buf);
    return count(&adapted.new_interface, result.flags);
}

test "default flags count lines words bytes" {
    const c = try countStr(std.testing.allocator, "hello world\nfoo bar\n", "");
    try std.testing.expectEqual(@as(usize, 2), c.lines);
    try std.testing.expectEqual(@as(usize, 4), c.words);
    try std.testing.expectEqual(@as(usize, 20), c.bytes);
}

test "flag c counts bytes" {
    const c = try countStr(std.testing.allocator, "hello\n", "-c");
    try std.testing.expectEqual(@as(usize, 6), c.bytes);
}

test "flag l counts lines" {
    const c = try countStr(std.testing.allocator, "a\nb\nc\n", "-l");
    try std.testing.expectEqual(@as(usize, 3), c.lines);
}

test "flag w counts words" {
    const c = try countStr(std.testing.allocator, "one two three\n", "-w");
    try std.testing.expectEqual(@as(usize, 3), c.words);
}

test "flag m counts chars" {
    // "héllo\n" — 'é' is 2 UTF-8 bytes, 1 char; total 6 chars (h + é + l + l + o + \n)
    const c = try countStr(std.testing.allocator, "h\xc3\xa9llo\n", "-m");
    try std.testing.expectEqual(@as(usize, 6), c.chars);
}

test "empty input" {
    const c = try countStr(std.testing.allocator, "", "");
    try std.testing.expectEqual(@as(usize, 0), c.bytes);
    try std.testing.expectEqual(@as(usize, 0), c.lines);
    try std.testing.expectEqual(@as(usize, 0), c.words);
}
