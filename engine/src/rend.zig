const std = @import("std");
const plat = @import("plat.zig");

pub const Buffer = struct{
    id: u32,
    desc: BufferDesc,
};
pub const BufferType = enum{
    Vertex,
    Index,
    Uniform,
    Storage,
    Instance,
};
pub const BufferDesc = struct{
    type: BufferType,
    size: u32,
};

pub const Texture = struct{
    id: u32,
    desc: TextureDesc,
};
pub const TextureDesc = struct{
    type: TextureType   = .Tex2D,
    usage: TextureUsage = .Sampler,
    fmt: TextureFormat  = .Rgba8,
    sampling: TextureSampling = .Nearest,
    wrap: TextureWrap = .Repeat,
    width: u32,
    height: u32,
    mipmaps: bool = false,
};
pub const TextureType = enum{
    Tex2D,
    Cubemap,
};
pub const TextureUsage = enum{
    Sampler,
    Target,
};
pub const TextureFormat = enum{
    Rgba8,
    Rgb8,
    R8,

    Rgba16f,
    Rgb16f,
    R16f,

    Rgba32f,
    Rgb32f,
    R32f,

    Depth24,
    Depth32f,
    Depth24Stencil8,
    Depth32fStencil8,
};
pub const TextureSampling = enum{
    Nearest,
    Linear,
};
pub const TextureWrap = enum{
    Repeat,
    // more
};

pub const VertexLayoutDesc = struct{
    stride: u32,
    attrs: []const VertexAttrDesc,
    type: VertexType,
};
pub const VertexAttrDesc = struct{
    location: u8,
    format: VertexFormat,
    offset: u32
};
pub const VertexType = enum{
    Vertex,
    Instance,
};

pub const VertexFormat = enum{
    // may expand later, prob not
    Float,
    Vector2,
    Vector3,
    Vector4,
};

pub const Topology = enum{
    Points,
    Lines,
    LineStrip,
    Triangles,
    TriangleStrip,
    TriangleFan,
};

pub const CullMode = enum{
    None,
    Back,
    Front,
};
pub const FrontFace = enum{
    CW,
    CCW,
};

pub const CompareOp = enum{
    Never,
    Less,
    Greater,
    Equal,
    NotEqual,
    LessEqual,
    GreaterEqual,
    Always,
};

pub const BlendState = struct{
    src_color: BlendFactor = .One,
    dst_color: BlendFactor = .Zero,
    color_op: BlendOp = .Add,
    src_alpha: BlendFactor = .One,
    dst_alpha: BlendFactor = .Zero,
    alpha_op: BlendOp = .Add,
};
pub const BlendFactor = enum{
    Zero,
    One,
    SrcColor,
    InvSrcColor,
    DstColor,
    InvDstColor,
    SrcAlpha,
    InvSrcAlpha,
    DstAlpha,
    InvDstAlpha,
};
pub const BlendOp = enum{
    Add,
    Subtract,
    RevSubtract,
    Min,
    Max,
};

pub const Pipeline = struct{
    id: u32,
    desc: PipelineDesc,
};
pub const PipelineDesc = struct{
    vertex_shader: *Shader,
    fragment_shader: *Shader,
    //...
    vertex_layout_desc: ?VertexLayoutDesc,

    topology: Topology = .Triangles,

    cull_mode: CullMode = .None,
    front_face: FrontFace = .CCW,

    depth_test: bool = false,
    depth_write: bool = false,
    depth_compare: CompareOp = .Less,

    blend: ?BlendState = null,

    //color_formats: []const TextureFormat,
    //depth_format: ?TextureFormat = null,
};

pub const Shader = struct{
    id: u32,
    desc: ShaderDesc,
};
pub const ShaderType = enum{
    Vertex,
    Fragment,
    // more later
};
pub const ShaderDesc = struct{
    type: ShaderType,
    source: [*:0]const u8,
};

pub const Impl = struct{
    pub fn make(self: *Impl, p_impl: *plat.Impl) anyerror !void { 
        try self.make_fn(self, p_impl); 
    }
    pub fn delete(self: *Impl) void { 
        self.delete_fn(self); 
    }

    pub fn resize(self: *Impl, width: u32, height: u32) void {
        self.resize_fn(self, width, height);
    }

    pub fn clear(self: *Impl, col: [4]f32) void { 
        self.clear_fn(self, col); 
    }

    pub fn make_buffer(self: *Impl, desc: BufferDesc, data: ?[]const u8) anyerror !Buffer { 
        return try self.make_buffer_fn(self, desc, data); 
    }
    pub fn delete_buffer(self: *Impl, buffer: *Buffer) void { 
        self.delete_buffer_fn(self, buffer); 
    }

    pub fn make_pipeline(self: *Impl, desc: PipelineDesc) anyerror !Pipeline {
        return try self.make_pipeline_fn(self, desc);
    }
    pub fn delete_pipeline(self: *Impl, pipeline: *Pipeline) void {
        self.delete_pipeline_fn(self, pipeline);
    }

    pub fn make_shader(self: *Impl, desc: ShaderDesc) anyerror !Shader {
        return try self.make_shader_fn(self, desc);
    }
    pub fn delete_shader(self: *Impl, shader: *Shader) void {
        self.delete_shader_fn(self, shader);
    }

    pub fn make_texture(self: *Impl, desc: TextureDesc, data: ?[]const u8) anyerror !Texture {
        return try self.make_texture_fn(self, desc, data);
    }
    pub fn delete_texture(self: *Impl, texture: *Texture) void {
        self.delete_texture_fn(self, texture);
    }

    pub fn bind_pipeline(self: *Impl, pipeline: *Pipeline) void {
        self.bind_pipeline_fn(self, pipeline);
    }
    pub fn bind_buffer(self: *Impl, buffer: *Buffer, slot: u32) void {
        self.bind_buffer_fn(self, buffer, slot);
    }
    pub fn bind_texture(self: *Impl, texture: *Texture, slot: u32, location: u32) void {
        self.bind_texture_fn(self, texture, slot, location);
    }

    pub fn draw(self: *Impl, vertex_count: u32, instance_count: u32) void {
        self.draw_fn(self, vertex_count, instance_count);
    }

    act: *anyopaque,
    name: []const u8,

    make_fn:   *const fn(self: *Impl, p_impl: *plat.Impl) anyerror !void,
    delete_fn: *const fn(self: *Impl) void,

    resize_fn: *const fn(self: *Impl, width: u32, height: u32) void,

    clear_fn: *const fn(self: *Impl, col: [4]f32) void,

    make_buffer_fn:   *const fn(self: *Impl, desc: BufferDesc, data: ?[]const u8) anyerror !Buffer,
    delete_buffer_fn: *const fn(self: *Impl, buffer: *Buffer) void,

    make_pipeline_fn:   *const fn(self: *Impl, desc: PipelineDesc) anyerror !Pipeline,
    delete_pipeline_fn: *const fn(self: *Impl, pipeline: *Pipeline) void,

    make_shader_fn:   *const fn(self: *Impl, desc: ShaderDesc) anyerror !Shader,
    delete_shader_fn: *const fn(self: *Impl, shader: *Shader) void,

    make_texture_fn:   *const fn(self: *Impl, desc: TextureDesc, data: ?[]const u8) anyerror !Texture,
    delete_texture_fn: *const fn(self: *Impl, texture: *Texture) void,

    bind_pipeline_fn: *const fn(self: *Impl, pipeline: *Pipeline) void,
    bind_buffer_fn:   *const fn(self: *Impl, buffer: *Buffer, slot: u32) void,
    bind_texture_fn:  *const fn(self: *Impl, texture: *Texture, slot: u32, location: u32) void,

    draw_fn: *const fn(self: *Impl, vertex_count: u32, instance_count: u32) void,
};
