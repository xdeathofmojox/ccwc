const FlagSet = @import("cc-wc-core-internal").flags.FlagSet;

pub const Args = struct {
    flags: FlagSet,
    files: []const []const u8,
};
