const std = @import("std");
const rend = @import("rend.zig");
const math = @import("math.zig");

pub const KeyState = enum{
    Released,
    Pressed,
    Held,
    Inactive,
};
pub const Key = enum{
    Escape,
    Caps,
    Space, Tab,
    Backspace, Delete,
    Home, End,
    PageUp, PageDown,
    Insert,

    LShift, RShift,
    LCtrl, RCtrl,
    LAlt, RAlt,
    LSuper, RSuper,

    Up, Left, Right, Down,

    A, B, C, D, E,
    F, G, H, I, J,
    K, L, M, N, O,
    P, Q, R, S, T,
    U, V, W, X, Y, Z,
    
    K1, K2, K3, K4, K5,
    K6, K7, K8, K9, K0,

    F1, F2, F3, F4,
    F5, F6, F7, F8,
    F9, F10, F11, F12,

    // add symbols and stuff
};

pub const Mouse = enum{
    Left, Right, Middle,
};

pub const Impl = struct{
    pub fn make(self: *Impl, r_impl: *rend.Impl, width: u32, height: u32, title: [:0]const u8) anyerror !void { 
        try self.make_fn(self, r_impl, width,height, title); 
    }
    pub fn delete(self: *Impl) void { 
        self.delete_fn(self); 
    }

    pub fn get_time(self: *Impl) f32 { 
        return self.get_time_fn(self); 
    }

    pub fn is_closed(self: *Impl) bool { 
        return self.is_closed_fn(self); 
    }
    pub fn poll(self: *Impl) anyerror !void { 
        try self.poll_fn(self); 
    }
    pub fn swap(self: *Impl) anyerror !void { 
        try self.swap_fn(self); 
    }

    pub fn gl_get_fn_addr(self: *Impl, name: [:0]const u8) anyerror !*anyopaque { return try self.gl_get_fn_addr_fn(self, name); }

    act: *anyopaque,
    name: []const u8,

    width: u32,
    height: u32,

    keys: [std.meta.fields(Key).len]KeyState,
    mousebuts: [std.meta.fields(Mouse).len]KeyState,
    mouse: math.Vec2,

    make_fn:   *const fn(self: *Impl, r_impl: *rend.Impl, width: u32, height: u32, title: [:0]const u8) anyerror !void,
    delete_fn: *const fn(self: *Impl) void,

    get_time_fn: *const fn(self: *Impl) f32,

    is_closed_fn: *const fn(self: *Impl) bool,
    poll_fn: *const fn(self: *Impl) anyerror !void,
    swap_fn: *const fn(self: *Impl) anyerror !void,

    // specific stuff

    gl_get_fn_addr_fn: *const fn(self: *Impl, name: [:0]const u8) anyerror !*anyopaque,
};
