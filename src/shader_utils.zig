const std = @import("std");

const zglfw = @import("zglfw");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

pub const ShaderProgram = struct {
    id: c_uint,

    pub fn init(comptime vertexPath: [:0]const u8, comptime fragmentPath: [:0]const u8) ShaderProgram {
        const vertexSource: [*c]const u8 = @embedFile(vertexPath);
        const fragmentSource: [*c]const u8 = @embedFile(fragmentPath);

        var success: c_int = 0;
        var infoLogBuffer: [512]u8 = undefined;
        const infoLog: [*c]u8 = @ptrCast(&infoLogBuffer);

        const vertexShader = gl.createShader(gl.VERTEX_SHADER);
        defer gl.deleteShader(vertexShader);
        gl.shaderSource(vertexShader, 1, &vertexSource, null);
        gl.compileShader(vertexShader);
        gl.getShaderiv(vertexShader, gl.COMPILE_STATUS, &success);
        if (success == 0) {
            gl.getShaderInfoLog(vertexShader, 512, null, infoLog);
            std.log.err("GL ERR: vertex shader compilation failed.\n\t{s}", .{infoLog});
        }

        const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
        defer gl.deleteShader(fragmentShader);
        gl.shaderSource(fragmentShader, 1, &fragmentSource, null);
        gl.compileShader(fragmentShader);
        gl.getShaderiv(fragmentShader, gl.COMPILE_STATUS, &success);
        if (success == 0) {
            gl.getShaderInfoLog(fragmentShader, 512, null, infoLog);
            std.log.err("GL ERR: fragment shader compilation failed.\n\t{s}", .{infoLog});
        }

        const shaderProgram = gl.createProgram();
        gl.attachShader(shaderProgram, vertexShader);
        gl.attachShader(shaderProgram, fragmentShader);
        gl.linkProgram(shaderProgram);
        gl.getProgramiv(shaderProgram, gl.LINK_STATUS, &success);
        if (success == 0) {
            gl.getProgramInfoLog(shaderProgram, 512, null, infoLog);
            std.log.err("GL ERR: shader program linkage failed.\n\t{s}", .{infoLog});
        }

        return ShaderProgram{
            .id = shaderProgram,
        };
    }

    pub fn deinit(self: ShaderProgram) void {
        defer gl.deleteProgram(self.id);
    }

    pub fn use(self: ShaderProgram) void {
        gl.useProgram(self.id);
    }

    pub fn setBool(self: ShaderProgram, name: [:0]const u8, value: bool) void {
        gl.uniform1i(gl.getUniformLocation(self.id, name), @intFromBool(value));
    }

    pub fn setInteger(self: ShaderProgram, name: [:0]const u8, value: i32) void {
        gl.uniform1i(gl.getUniformLocation(self.id, name), value);
    }

    pub fn setFloat(self: ShaderProgram, name: [:0]const u8, value: f32) void {
        gl.uniform1f(gl.getUniformLocation(self.id, name), value);
    }
};
