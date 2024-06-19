const std = @import("std");
const rl = @import("raylib");

const SCREEN_WIDTH = 640;
const SCREEN_HEIGHT = 480;

const RocketShip = struct {
    pos: rl.Vector2,
    theta: f32,
    width: f32,
    height: f32,
    fn init(x: f32, y: f32, theta: f32, width: f32, height: f32) RocketShip {
        return RocketShip{
            .pos = rl.Vector2.init(x, y),
            .theta = theta,
            .width = width,
            .height = height,
        };
    }
};

fn drawRocketShip(rocket: RocketShip) void {
    const v1 = rl.Vector2{ .x = 0, .y = -rocket.height / 2 };
    const v2 = rl.Vector2{ .x = -rocket.width / 2, .y = rocket.height / 2 };
    const v3 = rl.Vector2{ .x = rocket.width / 2, .y = rocket.height / 2 };
    rl.drawTriangleLines(
        v1.rotate(rocket.theta).add(rocket.pos),
        v2.rotate(rocket.theta).add(rocket.pos),
        v3.rotate(rocket.theta).add(rocket.pos),
        rl.Color.ray_white,
    );
}

pub fn main() !void {
    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "LARGE SPACE ROCKS");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    const velocity = 4.0;
    var rocket = RocketShip.init(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 0, 50, 60);

    while (!rl.windowShouldClose()) {
        // Update
        if (rl.isKeyDown(rl.KeyboardKey.key_left)) {
            rocket.theta -= 0.1;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_right)) {
            rocket.theta += 0.1;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_up)) {
            const vx = velocity * @sin(rocket.theta);
            const vy = -velocity * @cos(rocket.theta);
            rocket.pos = rocket.pos.add(rl.Vector2.init(vx, vy));
        }

        // Check boundaries
        if (rocket.pos.x < -rocket.width) {
            rocket.pos.x = SCREEN_WIDTH;
            rocket.pos.y = SCREEN_HEIGHT - rocket.pos.y;
        }
        if (rocket.pos.x > SCREEN_WIDTH + rocket.width) {
            rocket.pos.x = 0;
            rocket.pos.y = SCREEN_HEIGHT - rocket.pos.y;
        }
        if (rocket.pos.y < -rocket.height) {
            rocket.pos.x = SCREEN_WIDTH - rocket.pos.x;
            rocket.pos.y = SCREEN_HEIGHT;
        }
        if (rocket.pos.y > SCREEN_HEIGHT + rocket.height) {
            rocket.pos.x = SCREEN_WIDTH - rocket.pos.x;
            rocket.pos.y = 0;
        }

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        drawRocketShip(rocket);
    }
}
