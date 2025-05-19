const std = @import("std");

const zglfw = @import("zglfw");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

const glfwUtils = @import("glfw_utils.zig");
const shaderUtils = @import("shader_utils.zig");

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
    var app = try glfwUtils.App.init("Simple Planet", 800, 600);
    defer app.deinit();

    const shaderProgram = shaderUtils.ShaderProgram.init("shader/vertex.glsl", "shader/fragment.glsl");
    defer shaderProgram.deinit();

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

    gl.polygonMode(gl.FRONT_AND_BACK, gl.LINE);
    while (!app.window.shouldClose()) {
        gl.clearColor(0.2, 0.3, 0.3, 1);
        gl.clear(gl.COLOR_BUFFER_BIT);

        shaderProgram.use();
        gl.bindVertexArray(vao);

        gl.drawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, @ptrFromInt(0));

        zglfw.swapBuffers(app.window);
        zglfw.pollEvents();
    }
}
