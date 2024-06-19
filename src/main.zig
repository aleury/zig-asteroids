const std = @import("std");
const rl = @import("raylib");

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 640;

const SCREEN_CENTER = rl.Vector2.init(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);

const Timer = struct {
    time: f32,
    duration: f32,
    fn init(duration: f32) Timer {
        return Timer{ .time = 0.0, .duration = duration };
    }
    fn tick(self: *@This(), dt: f32) void {
        self.time += dt;
    }
    fn done(self: *@This()) bool {
        return self.time >= self.duration;
    }
    fn reset(self: *@This()) void {
        self.time = 0.0;
    }
};

const Rocket = struct {
    width: f32,
    height: f32,
    theta: f32,
    speed: f32,
    position: rl.Vector2,
};

const Asteroid = struct {
    width: f32,
    height: f32,
    theta: f32,
    angular_velocity: f32,
    velocity: rl.Vector2,
    position: rl.Vector2,
};

fn updateRocket(rocket: *Rocket) void {
    const vx = rocket.speed * @sin(rocket.theta);
    const vy = -rocket.speed * @cos(rocket.theta);
    rocket.position = rocket.position.add(rl.Vector2.init(vx, vy));
}

fn createAsteroid() Asteroid {
    const px = rl.getRandomValue(60, SCREEN_WIDTH - 60);
    const size: f32 = @floatFromInt(rl.getRandomValue(30, 100));

    return Asteroid{
        .width = size,
        .height = size,
        .theta = 0.0,
        .angular_velocity = 1.0,
        .velocity = rl.Vector2.init(0.0, 1.5),
        .position = rl.Vector2.init(@floatFromInt(px), -100.0),
    };
}

fn updateAsteroid(asteroid: *Asteroid, dt: f32) void {
    asteroid.theta += asteroid.angular_velocity * dt;
    asteroid.position = asteroid.position.add(asteroid.velocity);
}

fn drawTriangle(v1: rl.Vector2, v2: rl.Vector2, v3: rl.Vector2, color: rl.Color) void {
    rl.drawTriangleLines(v1, v2, v3, color);
}

fn drawRocket(rocket: Rocket) void {
    const v1 = rl.Vector2{ .x = 0, .y = -rocket.height / 2 };
    const v2 = rl.Vector2{ .x = -rocket.width / 2, .y = rocket.height / 2 };
    const v3 = rl.Vector2{ .x = rocket.width / 2, .y = rocket.height / 2 };
    drawTriangle(
        v1.rotate(rocket.theta).add(rocket.position),
        v2.rotate(rocket.theta).add(rocket.position),
        v3.rotate(rocket.theta).add(rocket.position),
        rl.Color.ray_white,
    );
}

fn drawAsteroid(asteroid: Asteroid) void {
    const v1 = rl.Vector2{ .x = 0, .y = -asteroid.height / 2 };
    const v2 = rl.Vector2{ .x = -asteroid.width / 2, .y = asteroid.height / 2 };
    const v3 = rl.Vector2{ .x = asteroid.width / 2, .y = asteroid.height / 2 };
    drawTriangle(
        v1.rotate(asteroid.theta).add(asteroid.position),
        v2.rotate(asteroid.theta).add(asteroid.position),
        v3.rotate(asteroid.theta).add(asteroid.position),
        rl.Color.ray_white,
    );
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "LARGE SPACE ROCKS");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var rocket = Rocket{
        .width = 25,
        .height = 30,
        .theta = 0.0,
        .speed = 1.0,
        .position = SCREEN_CENTER,
    };

    // Setup asteroids collection
    // var asteroid_timer: f32 = 0.0;
    var asteroid_timer = Timer.init(2.0);
    var asteroids = std.ArrayList(Asteroid).init(gpa.allocator());
    defer asteroids.deinit();

    while (!rl.windowShouldClose()) {
        const dt = rl.getFrameTime();

        // spawn asteroids
        asteroid_timer.tick(dt);
        if (asteroid_timer.done()) {
            try asteroids.append(createAsteroid());
            asteroid_timer.reset();
        }

        // handle input
        if (rl.isKeyDown(rl.KeyboardKey.key_left)) {
            rocket.theta -= 0.1;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_right)) {
            rocket.theta += 0.1;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_up)) {
            rocket.speed += 0.15;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_down)) {
            rocket.speed -= 0.15;
        }

        // Update
        updateRocket(&rocket);
        for (0..asteroids.items.len) |i| {
            updateAsteroid(&asteroids.items[i], dt);
        }

        // Check boundaries
        if (rocket.position.x < -rocket.width) {
            rocket.position.x = SCREEN_WIDTH;
            rocket.position.y = SCREEN_HEIGHT - rocket.position.y;
        }
        if (rocket.position.x > SCREEN_WIDTH + rocket.width) {
            rocket.position.x = 0;
            rocket.position.y = SCREEN_HEIGHT - rocket.position.y;
        }
        if (rocket.position.y < -rocket.height) {
            rocket.position.x = SCREEN_WIDTH - rocket.position.x;
            rocket.position.y = SCREEN_HEIGHT;
        }
        if (rocket.position.y > SCREEN_HEIGHT + rocket.height) {
            rocket.position.x = SCREEN_WIDTH - rocket.position.x;
            rocket.position.y = 0;
        }

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        drawRocket(rocket);
        for (asteroids.items) |asteroid| {
            drawAsteroid(asteroid);
        }
    }
}
