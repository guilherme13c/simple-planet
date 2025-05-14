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
    var app = glfw_setup.glfwApp.init(800, 600) orelse return;
    defer app.deinit();

    const shaderProgram = try gl_shader_setup.shaderProgram.init(vertexShaderSrc, fragmentShaderSrc);
    defer shaderProgram.deinit();

    glfw.glfwSetInputMode(app.window, glfw.GLFW_STICKY_KEYS, glfw.GLFW_TRUE);

    var vbo: c_uint = 0;
    var vao: c_uint = 0;
    var ebo: c_uint = 0;

    {
        gl.glGenVertexArrays(1, &vao);
        gl.glGenBuffers(1, &vbo);
        gl.glGenBuffers(1, &ebo);

        gl.glBindVertexArray(vao);

        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, vbo);
        gl.glBufferData(gl.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), &vertices, gl.GL_STATIC_DRAW);

        gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, ebo);
        gl.glBufferData(gl.GL_ELEMENT_ARRAY_BUFFER, @sizeOf(@TypeOf(indices)), &indices, gl.GL_STATIC_DRAW);

        gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 3 * @sizeOf(f32), @ptrFromInt(0));
        gl.glEnableVertexAttribArray(0);

        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, 0);
        gl.glBindVertexArray(0);
    }

    defer gl.glDeleteVertexArrays(1, &vao);
    defer gl.glDeleteBuffers(1, &vbo);
    defer gl.glDeleteBuffers(1, &ebo);

    gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_LINE);
    while (glfw.glfwGetKey(app.window, glfw.GLFW_KEY_ESCAPE) != glfw.GLFW_PRESS and glfw.glfwWindowShouldClose(app.window) == 0) {
        gl.glClearColor(0, 0, 0, 1);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);

        {
            gl.glUseProgram(shaderProgram.prog);
            gl.glBindVertexArray(vao);
            gl.glDrawElements(gl.GL_TRIANGLES, 6, gl.GL_UNSIGNED_INT, @ptrFromInt(0));
        }

        glfw.glfwSwapBuffers(app.window);
        glfw.glfwPollEvents();
    }

    return;
}
