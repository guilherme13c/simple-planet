const std = @import("std");

const zglfw = @import("zglfw");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

const gl_major = 4;
const gl_minor = 0;

pub const App = struct {
    window: *zglfw.Window,
    width: u16,
    height: u16,
    title: [:0]const u8,

    pub fn init(title: [:0]const u8, width: u16, height: u16) !App {
        try zglfw.init();

        zglfw.windowHint(.context_version_major, gl_major);
        zglfw.windowHint(.context_version_minor, gl_minor);
        zglfw.windowHint(.opengl_profile, .opengl_core_profile);
        zglfw.windowHint(.opengl_forward_compat, true);
        zglfw.windowHint(.client_api, .opengl_api);
        zglfw.windowHint(.doublebuffer, true);

        const window = try zglfw.Window.create(@intCast(width), @intCast(height), title, null);

        _ = zglfw.setErrorCallback(glfwErrorCallback);
        _ = zglfw.setFramebufferSizeCallback(window, glfwFramebufferSizeCallback);

        zglfw.makeContextCurrent(window);

        try zopengl.loadCoreProfile(zglfw.getProcAddress, gl_major, gl_minor);

        zglfw.swapInterval(1);

        return App{
            .window = window,
            .width = width,
            .height = height,
            .title = title,
        };
    }

    pub fn deinit(self: App) void {
        self.window.destroy();
        zglfw.terminate();
    }

    fn glfwErrorCallback(err: c_int, description: ?[*:0]const u8) callconv(.c) void {
        _ = err;
        std.log.err("GLFW ERR:\t{any}", .{description});
    }

    fn glfwFramebufferSizeCallback(window: *zglfw.Window, width: c_int, height: c_int) callconv(.c) void {
        _ = window;
        gl.viewport(0, 0, width, height);
    }
};
