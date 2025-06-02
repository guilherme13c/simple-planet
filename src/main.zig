const std = @import("std");

const rl = @import("raylib");

pub fn main() !void {
    rl.setTraceLogLevel(rl.TraceLogLevel.err);

    rl.initWindow(
        800,
        600,
        "simple planet",
    );
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    const camera = rl.Camera3D{
        .position = .{ .x = 10, .y = 10, .z = 10 },
        .target = .{ .x = 0, .y = 0, .z = 0 },
        .projection = .perspective,
        .up = .{ .x = 0, .y = 1, .z = 0 },
        .fovy = 45,
    };

    var rotationX: f32 = 0.0;
    var rotationY: f32 = 0.0;
    var rotationZ: f32 = 0.0;

    var model = try rl.loadModel("src/resources/models/dodecahedron.obj");

    while (!rl.windowShouldClose()) {
        const deltaTime = rl.getFrameTime();

        rotationX += 0.5 * deltaTime;
        rotationY += 0.3 * deltaTime;
        rotationZ += 0.2 * deltaTime;

        const rotationMatrix = rl.math.matrixRotateXYZ(.{
            .x = rotationX,
            .y = rotationY,
            .z = rotationZ,
        });

        model.transform = rotationMatrix;

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.beginMode3D(camera);
        defer rl.endMode3D();

        rl.clearBackground(rl.Color.black);

        model.draw(.{ .x = 0, .y = 0, .z = 0 }, 3, rl.Color.ray_white);

        rl.drawFPS(10, 10);
    }
}
