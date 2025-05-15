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

const width = 800;
const height = 600;

const Mat4 = [4][4]f32;
const Vec3 = [3]f32;

fn perspective(fovy: f32, aspect: f32, near: f32, far: f32) Mat4 {
    const f = 1.0 / @tan(fovy / 2.0);
    return Mat4{
        .{ f / aspect, 0, 0, 0 },
        .{ 0, f, 0, 0 },
        .{ 0, 0, (far + near) / (near - far), -1 },
        .{ 0, 0, (2 * far * near) / (near - far), 0 },
    };
}

fn lookAt(eye: Vec3, center: Vec3, up: Vec3) Mat4 {
    const fx = center[0] - eye[0];
    const fy = center[1] - eye[1];
    const fz = center[2] - eye[2];
    const flen = @sqrt(fx * fx + fy * fy + fz * fz);
    const f: Vec3 = .{ fx / flen, fy / flen, fz / flen };

    const sx = f[1] * up[2] - f[2] * up[1];
    const sy = f[2] * up[0] - f[0] * up[2];
    const sz = f[0] * up[1] - f[1] * up[0];
    const slen = @sqrt(sx * sx + sy * sy + sz * sz);
    const s: Vec3 = .{ sx / slen, sy / slen, sz / slen };

    const ux = s[1] * f[2] - s[2] * f[1];
    const uy = s[2] * f[0] - s[0] * f[2];
    const uz = s[0] * f[1] - s[1] * f[0];

    return Mat4{
        .{ s[0], ux, -f[0], 0 },
        .{ s[1], uy, -f[1], 0 },
        .{ s[2], uz, -f[2], 0 },
        .{ -(s[0] * eye[0] + s[1] * eye[1] + s[2] * eye[2]), -(ux * eye[0] + uy * eye[1] + uz * eye[2]), (f[0] * eye[0] + f[1] * eye[1] + f[2] * eye[2]), 1 },
    };
}

const vertices = [_]f32{
    -1,            std.math.phi,  0,
    1,             std.math.phi,  0,
    -1,            -std.math.phi, 0,
    1,             -std.math.phi, 0,
    0,             -1,            std.math.phi,
    0,             1,             std.math.phi,
    0,             -1,            -std.math.phi,
    0,             1,             -std.math.phi,
    std.math.phi,  0,             -1,
    std.math.phi,  0,             1,
    -std.math.phi, 0,             -1,
    -std.math.phi, 0,             1,
};

const indices = [_]c_int{
    0, 11, 5, 0, 5,  1,  0,  1,  7,  0,  7, 10, 0, 10, 11,
    1, 5,  9, 5, 11, 4,  11, 10, 2,  10, 7, 6,  7, 1,  8,
    3, 9,  4, 3, 4,  2,  3,  2,  6,  3,  6, 8,  3, 8,  9,
    4, 9,  5, 2, 4,  11, 6,  2,  10, 8,  6, 7,  9, 8,  1,
};

pub fn main() !void {
    var app = glfw_setup.glfwApp.init(width, height) orelse return;
    defer app.deinit();

    const shaderProgram = try gl_shader_setup.shaderProgram.init(vertexShaderSrc, fragmentShaderSrc);
    defer shaderProgram.deinit();

    const projLoc = gl.glGetUniformLocation(shaderProgram.prog, "uProjection");
    const viewLoc = gl.glGetUniformLocation(shaderProgram.prog, "uView");
    const uModelLoc = gl.glGetUniformLocation(shaderProgram.prog, "uModel");

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

    gl.glEnable(gl.GL_DEPTH_TEST);
    gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_LINE);

    const proj = perspective(
        std.math.degreesToRadians(45.0),
        width / height,
        0.1,
        100.0,
    );
    const view = lookAt(
        .{ 0, 0, 10 },
        .{ 0, 0, 0 },
        .{ 0, 1, 0 },
    );

    gl.glUseProgram(shaderProgram.prog);
    gl.glUniformMatrix4fv(projLoc, 1, gl.GL_FALSE, &proj[0][0]);
    gl.glUniformMatrix4fv(viewLoc, 1, gl.GL_FALSE, &view[0][0]);

    while (glfw.glfwGetKey(app.window, glfw.GLFW_KEY_ESCAPE) != glfw.GLFW_PRESS and glfw.glfwWindowShouldClose(app.window) == 0) {
        const t: f32 = @floatCast(glfw.glfwGetTime());
        const model = rotationY(t);
        gl.glUniformMatrix4fv(uModelLoc, 1, gl.GL_FALSE, &model[0][0]);

        gl.glClearColor(0, 0, 0, 1);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT);

        {
            gl.glUseProgram(shaderProgram.prog);

            gl.glBindVertexArray(vao);
            gl.glDrawElements(
                gl.GL_TRIANGLES,
                @sizeOf(@TypeOf(indices)) / @sizeOf(@TypeOf(indices[0])),
                gl.GL_UNSIGNED_INT,
                @ptrFromInt(0),
            );
        }

        glfw.glfwSwapBuffers(app.window);
        glfw.glfwPollEvents();
    }

    return;
}

fn rotationY(angle: f32) Mat4 {
    const c = @cos(angle);
    const s = @sin(angle);
    return Mat4{
        .{ c, 0, s, 0 },
        .{ 0, 1, 0, 0 },
        .{ -s, 0, c, 0 },
        .{ 0, 0, 0, 1 },
    };
}
