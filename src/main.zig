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

    app.run();

    return;
}
