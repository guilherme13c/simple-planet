const std = @import("std");

const gl = @cImport(@cInclude("glad/glad.h"));
const glfw = @cImport({
    @cDefine("GLFW_INCLUDE_NONE", {});
    @cInclude("GLFW/glfw3.h");
});

pub const glfwApp = struct {
    width: u32,
    height: u32,
    window: ?*glfw.struct_GLFWwindow,

    fn glfwErrCallback(err: c_int, desc: [*c]const u8) callconv(.c) void {
        std.log.err("GLFW ERR: {} {s}\n", .{ err, desc });
    }

    fn glfwFrameBufferSizeCallback(window: ?*glfw.GLFWwindow, width: c_int, height: c_int) callconv(.c) void {
        _ = window;
        gl.glViewport(0, 0, width, height);
    }

    pub fn init(window_width: u32, window_height: u32) ?glfwApp {
        if (glfw.glfwInit() != glfw.GLFW_TRUE) {
            return null;
        }

        _ = glfw.glfwSetErrorCallback(glfwErrCallback);

        glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MAJOR, 3);
        glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MINOR, 3);
        glfw.glfwWindowHint(glfw.GLFW_OPENGL_PROFILE, glfw.GLFW_OPENGL_CORE_PROFILE);
        glfw.glfwWindowHint(glfw.GLFW_OPENGL_FORWARD_COMPAT, glfw.GLFW_TRUE);

        var win: *glfw.GLFWwindow = undefined;
        win = glfw.glfwCreateWindow(
            @as(c_int, @intCast(window_width)),
            @as(c_int, @intCast(window_height)),
            "Simple Planet",
            null,
            null,
        ) orelse return null;

        glfw.glfwMakeContextCurrent(win);
        _ = glfw.glfwSetFramebufferSizeCallback(win, glfwFrameBufferSizeCallback);

        const version = gl.gladLoadGL();
        if (version == 0) {
            return null;
        }

        return glfwApp{
            .width = window_width,
            .height = window_height,
            .window = win,
        };
    }

    pub fn deinit(self: glfwApp) void {
        glfw.glfwDestroyWindow(self.window);
        glfw.glfwTerminate();
    }
};
