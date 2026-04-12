const std = @import("std");
const Flag = @import("flag.zig").Flag;

pub const FlagSet = std.EnumSet(Flag);