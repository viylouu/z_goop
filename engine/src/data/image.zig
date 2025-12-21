const std = @import("std");
const zi = @import("zigimg");

pub const Rgba8 = struct{
    data: []u8,
    width: u32,
    height: u32,

    pub fn deinit(self: *Rgba8, alloc: std.mem.Allocator) void {
        alloc.free(self.data);
    }
};

pub fn load_rgba8(alloc: std.mem.Allocator, bytes: []const u8) !Rgba8 {
    var img = try zi.Image.fromMemory(alloc, bytes);
    defer img.deinit(alloc);

    try img.convert(alloc, .rgba32);

    const rgba = img.pixels.rgba32;
    const rgba_u8 = std.mem.sliceAsBytes(rgba);

    return .{
        .width  = @intCast(img.width),
        .height = @intCast(img.height),
        .data   = try alloc.dupe(u8, rgba_u8),
    };
}

