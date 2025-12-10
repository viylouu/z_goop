const std = @import("std");

const EngineError = error{
    InitFailure,
    UpdateFailure,
    ExitFailure
};

pub fn run(api: struct{
    init:   fn() EngineError !void,
    update: fn(dt: f32) EngineError !void,
    exit:   fn() EngineError !void,

    title:  []const u8,
    width:  u32,
    height: u32,
}) !void {
    try api.init();
    try api.update(1.0/60.0);
    try api.exit();
}
