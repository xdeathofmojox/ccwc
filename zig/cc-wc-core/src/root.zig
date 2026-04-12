pub const execute = @import("cc-wc-core-internal").execution.execute;

test {
    @import("std").testing.refAllDeclsRecursive(@This());
}
