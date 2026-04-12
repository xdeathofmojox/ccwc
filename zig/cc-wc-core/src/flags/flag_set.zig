const std = @import("std");
const Flag = @import("cc-wc-core-internal").flags.Flag;

pub const FlagSet = std.EnumSet(Flag);
