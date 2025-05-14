const std = @import("std");

const gl_shader_setup = @import("gl_shader_setup.zig");
const glfw_setup = @import("glfw_setup.zig");

const gl = @cImport(@cInclude("glad/glad.h"));
const glfw = @cImport({
    @cDefine("GLFW_INCLUDE_NONE", {});
    @cInclude("GLFW/glfw3.h");
});

const vertexShaderSrc = @embedFile("shader/vert.glsl");
const fragmentShaderSrc = @embedFile("shader/frag.glsl");

fn loop() void {}

pub fn main() !void {
    var app = glfw_setup.glfwApp.init(800, 600, loop) orelse return;
    defer app.deinit();

    const prog = try gl_shader_setup.shaderProgram.init(vertexShaderSrc, fragmentShaderSrc);
    _ = prog;
    const cube = try createCube();
    _ = cube;

    app.run();

    return;
}

fn createCube() !struct {
    vao: u32,
    vbo: u32,
    ebo: u32,
} {
    const vao: u32 = 0;
    const vbo: u32 = 0;
    const ebo: u32 = 0;

    return .{ .vao = vao, .vbo = vbo, .ebo = ebo };
}

const cubeVertices = [_]f32{
    // positions       // colors
    -0.5, -0.5, -0.5, 1.0, 0.0, 0.0,
    0.5,  -0.5, -0.5, 0.0, 1.0, 0.0,
    0.5,  0.5,  -0.5, 0.0, 0.0, 1.0,
    -0.5, 0.5,  -0.5, 1.0, 1.0, 0.0,
    // and front face...
    -0.5, -0.5, 0.5,  1.0, 0.0, 1.0,
    0.5,  -0.5, 0.5,  0.0, 1.0, 1.0,
    0.5,  0.5,  0.5,  1.0, 1.0, 1.0,
    -0.5, 0.5,  0.5,  0.2, 0.2, 0.2,
};

const cubeIndices = [_]u32{
    0, 1, 2, 2, 3, 0, // back
    4, 5, 6, 6, 7, 4, // front
    4, 5, 1, 1, 0, 4, // bottom
    7, 6, 2, 2, 3, 7, // top
    5, 6, 2, 2, 1, 5, // right
    4, 7, 3, 3, 0, 4, // left
};
