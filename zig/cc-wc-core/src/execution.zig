const std = @import("std");
const arguments = @import("cc-wc-core-internal").arguments;
const counting = @import("cc-wc-core-internal").counting;
const FlagSet = @import("cc-wc-core-internal").flags.FlagSet;

const READ_BUF_SIZE = 64 * 1024;

pub fn execute(args: []const []const u8) u8 {
    const parsed = arguments.parseFlagsAndFilenames(args) catch return 1;

    if (parsed.files.len == 0) {
        return processStdin(parsed.flags);
    }
    return processFiles(parsed.flags, parsed.files);
}

fn processStdin(flags: FlagSet) u8 {
    var read_buf: [READ_BUF_SIZE]u8 = undefined;
    var reader = std.fs.File.Reader.initStreaming(std.fs.File.stdin(), &read_buf);
    const counts = counting.count(&reader.interface, flags) catch return 1;

    var write_buf: [64]u8 = undefined;
    var writer = std.fs.File.Writer.initStreaming(std.fs.File.stdout(), &write_buf);
    counting.printCounts(flags, counts, &writer.interface);
    writer.interface.print("\n", .{}) catch {};
    writer.interface.flush() catch {};
    return 0;
}

fn processFiles(flags: FlagSet, filepaths: []const []const u8) u8 {
    var status: u8 = 0;
    var write_buf: [4096]u8 = undefined;
    var stdout_writer = std.fs.File.Writer.initStreaming(std.fs.File.stdout(), &write_buf);
    for (filepaths) |filepath| {
        if (std.mem.eql(u8, filepath, "-")) {
            status = processStdin(flags);
        } else {
            processFile(flags, filepath, &status, &stdout_writer.interface);
        }
    }
    stdout_writer.interface.flush() catch {};
    return status;
}

fn processFile(flags: FlagSet, filepath: []const u8, status: *u8, stdout: *std.Io.Writer) void {
    const file = std.fs.cwd().openFile(filepath, .{}) catch {
        var err_buf: [256]u8 = undefined;
        var w = std.fs.File.Writer.initStreaming(std.fs.File.stderr(), &err_buf);
        w.interface.print("ccwc: {s}: No such file or directory\n", .{filepath}) catch {};
        w.interface.flush() catch {};
        status.* = 1;
        return;
    };
    defer file.close();

    var read_buf: [READ_BUF_SIZE]u8 = undefined;
    var reader = std.fs.File.Reader.initStreaming(file, &read_buf);
    const counts = counting.count(&reader.interface, flags) catch {
        status.* = 1;
        return;
    };
    counting.printCounts(flags, counts, stdout);
    stdout.print(" {s}\n", .{filepath}) catch {};
}
