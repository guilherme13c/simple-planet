const std = @import("std");

const gl = @cImport({
    @cInclude("glad/glad.h");
});

pub const shaderProgram = struct {
    prog: u32,

    fn compileShader(src: [*c]const u8, shaderType: u32) !u32 {
        const id = gl.glCreateShader(shaderType);
        gl.glShaderSource(id, 1, &src, null);
        gl.glCompileShader(id);

        var success: i32 = 0;
        gl.glGetShaderiv(id, gl.GL_COMPILE_STATUS, &success);
        if (success == 0) {
            var buf: [512]u8 = undefined;
            gl.glGetShaderInfoLog(id, buf.len, null, &buf[0]);
            std.log.err("Shader compile error: {s}\n", .{&buf});
            return error.ShaderCompileFailed;
        }
        return id;
    }

    fn createProgram(vertexSrc: [*c]const u8, fragmentSrc: [*c]const u8) !u32 {
        const vert = try compileShader(vertexSrc, gl.GL_VERTEX_SHADER);
        defer gl.glDeleteShader(vert);

        const frag = try compileShader(fragmentSrc, gl.GL_FRAGMENT_SHADER);
        defer gl.glDeleteShader(frag);

        const prog = gl.glCreateProgram();
        gl.glAttachShader(prog, vert);
        gl.glAttachShader(prog, frag);
        gl.glLinkProgram(prog);

        var success: i32 = 0;
        gl.glGetProgramiv(prog, gl.GL_LINK_STATUS, &success);
        if (success == 0) {
            var buf: [512]u8 = undefined;
            gl.glGetProgramInfoLog(prog, buf.len, null, &buf[0]);
            std.log.err("Program link error: {s}\n", .{&buf});
            return error.ProgramLinkFailed;
        }

        return prog;
    }

    pub fn init(vertexSrc: [*c]const u8, fragmentSrc: [*c]const u8) !shaderProgram {
        const prog = try createProgram(vertexSrc, fragmentSrc);

        return shaderProgram{
            .prog = prog,
        };
    }

    pub fn deinit(self: shaderProgram) void {
        gl.glDeleteProgram(self.prog);
    }
};
