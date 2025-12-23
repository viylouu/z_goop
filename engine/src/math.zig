const std = @import("std");

pub const Vec2 = struct{ x: f32, y: f32 };
pub const Vec3 = struct{ x: f32, y: f32, z: f32 };
pub const Vec4 = struct{ x: f32, y: f32, z: f32, w: f32 };

pub const Mat4 = struct{
    data: [16]f32,

    pub fn identity() Mat4 {
        return Mat4{ .data = .{
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1,
        }, };
    }

    pub fn multiply(a: Mat4, b: Mat4) Mat4 {
        var res: Mat4 = Mat4{ .data = undefined, };
        for (0..3) |r| { for (0..3) |c| 
            res[r*4 + c] =
                a.data[r*4 + 0] * b.data[0*4 + c] +
                a.data[r*4 + 1] * b.data[1*4 + c] +
                a.data[r*4 + 2] * b.data[2*4 + c] +
                a.data[r*4 + 3] * b.data[3*4 + c]; }
        return res;
    }
    pub fn multiply_vec(a: Mat4, b: Vec4) Vec4 {
        return Vec4{
            .x = a.data[0]  * b.x + a.data[1]  * b.y + a.data[2]  * b.z + a.data[3]  * b.w,
            .y = a.data[4]  * b.x + a.data[5]  * b.y + a.data[6]  * b.z + a.data[7]  * b.w,
            .z = a.data[8]  * b.x + a.data[9]  * b.y + a.data[10] * b.z + a.data[11] * b.w,
            .w = a.data[12] * b.x + a.data[13] * b.y + a.data[14] * b.z + a.data[15] * b.w,
        };
    }

    pub fn ortho(
        left: f32, right: f32,
        bottom: f32, top: f32,
        near: f32, far: f32,
    ) Mat4 {
        const rl = right - left;
        const tb = top - bottom;
        const fan = far - near;

        return Mat4{ .data = .{
            2.0/rl, 0, 0, 0,
            0, 2.0/tb, 0, 0,
            0, 0,-2.0/fan,0,
            -(right+left) / rl, -(top+bottom) / tb, -(far+near) / fan, 1,
        }, };
    }

    pub fn trans(pos: Vec3) Mat4 {
        return Mat4{ .data = .{
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            pos.x, pos.y, pos.z, 1,
        }, };
    }

    pub fn scale(size: Vec3) Mat4 {
        return Mat4{ .data = .{
            size.x, 0, 0, 0,
            0, size.y, 0, 0,
            0, 0, size.z, 0,
            0, 0, 0, 1,
        }, };
    }

    pub fn rotX(ang: f32) Mat4 {
        const c = @cos(ang);
        const s = @sin(ang);

        return Mat4{ .data = .{
            1, 0, 0, 0,
            0, c,-s, 0,
            0, s, c, 0,
            0, 0, 0, 1,
        }, };
    }
    pub fn rotY(ang: f32) Mat4 {
        const c = @cos(ang);
        const s = @sin(ang);

        return Mat4{ .data = .{
            c, 0, s, 0,
            0, 0, 0, 0,
           -s, 0, c, 0,
            0, 0, 0, 1,
        }, };
    }
    pub fn rotZ(ang: f32) Mat4 {
        const c = @cos(ang);
        const s = @sin(ang);

        return Mat4{ .data = .{
            c,-s, 0, 0,
            s, c, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1,
        }, };
    }

    pub fn rot(ang: Vec3) Mat4 {
        return Mat4.rotX(ang.x)
            .multiply(Mat4.rotY(ang.y))
            .multiply(Mat4.rotZ(ang.z));
    }

    pub fn transf(pos: Vec3, size: Vec3, ang: Vec3) Mat4 {
        return Mat4.trans(pos)
            .multiply(Mat4.rot(ang))
            .multiply(Mat4.scale(size));
    }
};
