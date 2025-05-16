const std = @import("std");

const zglfw = @import("zglfw");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

const vertexShaderSrc: [*c]const u8 = @embedFile("shader/vertex.glsl");
const fragmentShaderSrc: [*c]const u8 = @embedFile("shader/fragment.glsl");

const vertices = [_]f32{
    0.5,  0.5,  0.0,
    0.5,  -0.5, 0.0,
    -0.5, -0.5, 0.0,
    -0.5, 0.5,  0.0,
};
const indices = [_]c_int{
    0, 1, 3,
    1, 2, 3,
};

pub fn main() !void {
    const gl_major = 4;
    const gl_minor = 0;

    zglfw.windowHint(.context_version_major, gl_major);
    zglfw.windowHint(.context_version_minor, gl_minor);
    zglfw.windowHint(.opengl_profile, .opengl_core_profile);
    zglfw.windowHint(.opengl_forward_compat, true);
    zglfw.windowHint(.client_api, .opengl_api);
    zglfw.windowHint(.doublebuffer, true);

    try zglfw.init();
    defer zglfw.terminate();

    _ = zglfw.setErrorCallback(glfwErrorCallback);

    const window = try zglfw.Window.create(800, 600, "Simple Planet", null);
    defer window.destroy();

    _ = zglfw.setFramebufferSizeCallback(window, glfwFramebufferSizeCallback);

    zglfw.makeContextCurrent(window);

    try zopengl.loadCoreProfile(zglfw.getProcAddress, gl_major, gl_minor);

    zglfw.swapInterval(1);

    var success: c_int = 0;
    var infoLogBuffer: [512]u8 = undefined;
    const infoLog: [*c]u8 = @ptrCast(&infoLogBuffer);

    const vertexShader = gl.createShader(gl.VERTEX_SHADER);
    gl.shaderSource(vertexShader, 1, &vertexShaderSrc, null);
    gl.compileShader(vertexShader);
    gl.getShaderiv(vertexShader, gl.COMPILE_STATUS, &success);
    if (success == 0) {
        gl.getShaderInfoLog(vertexShader, 512, null, infoLog);
        std.log.err("GL ERR: vertex shader compilation failed.\n\t{s}", .{infoLog});
    }

    const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
    gl.shaderSource(fragmentShader, 1, &fragmentShaderSrc, null);
    gl.compileShader(fragmentShader);
    gl.getShaderiv(fragmentShader, gl.COMPILE_STATUS, &success);
    if (success == 0) {
        gl.getShaderInfoLog(fragmentShader, 512, null, infoLog);
        std.log.err("GL ERR: fragment shader compilation failed.\n\t{s}", .{infoLog});
    }

    const shaderProgram = gl.createProgram();
    defer gl.deleteProgram(shaderProgram);
    gl.attachShader(shaderProgram, vertexShader);
    gl.attachShader(shaderProgram, fragmentShader);
    gl.linkProgram(shaderProgram);
    gl.getProgramiv(shaderProgram, gl.LINK_STATUS, &success);
    if (success == 0) {
        gl.getProgramInfoLog(shaderProgram, 512, null, infoLog);
        std.log.err("GL ERR: shader program linkage failed.\n\t{s}", .{infoLog});
    }
    gl.deleteShader(vertexShader);
    gl.deleteShader(fragmentShader);

    var vao: c_uint = undefined;
    var vbo: c_uint = undefined;
    var ebo: c_uint = undefined;

    gl.genVertexArrays(1, @ptrCast(&vao));
    defer gl.deleteVertexArrays(1, @ptrCast(&vao));

    gl.genBuffers(1, @ptrCast(&vbo));
    defer gl.deleteBuffers(1, @ptrCast(&vbo));

    gl.genBuffers(1, @ptrCast(&ebo));
    defer gl.deleteBuffers(1, @ptrCast(&ebo));

    gl.bindVertexArray(vao);

    gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
    gl.bufferData(gl.ARRAY_BUFFER, vertices.len * @sizeOf(@TypeOf(vertices[0])), &vertices[0], gl.STATIC_DRAW);

    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices.len * @sizeOf(@TypeOf(indices[0])), &indices[0], gl.STATIC_DRAW);

    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), @ptrFromInt(0));
    gl.enableVertexAttribArray(0);

    while (!window.shouldClose()) {
        gl.clearColor(0.2, 0.3, 0.3, 1);
        gl.clear(gl.COLOR_BUFFER_BIT);

        gl.useProgram(shaderProgram);
        gl.bindVertexArray(vao);

        gl.drawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, @ptrFromInt(0));

        zglfw.swapBuffers(window);
        zglfw.pollEvents();
    }
}

fn glfwErrorCallback(err: c_int, description: ?[*:0]const u8) callconv(.c) void {
    _ = err;
    std.log.err("GLFW ERR:\t{any}", .{description});
}

fn glfwFramebufferSizeCallback(window: *zglfw.Window, width: c_int, height: c_int) callconv(.c) void {
    _ = window;
    gl.viewport(0, 0, width, height);
}
