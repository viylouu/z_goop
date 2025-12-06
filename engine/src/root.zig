const std = @import("std");

const EngineError = error{
    InitFailure,
    UpdateFailure,
    ExitFailure
};

pub const Game = struct{
    init: fn() EngineError !void,
    update: fn(dt: f32) EngineError !void,
    exit: fn() EngineError !void,
};

pub fn run(api: Game) !void {
    try api.init();
    try api.update(1.0/60.0);
    try api.exit();
}
