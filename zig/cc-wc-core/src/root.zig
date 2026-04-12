pub const runner = @import("cc-wc-core-internal").runner;

test {
    @import("std").testing.refAllDeclsRecursive(@This());
}
