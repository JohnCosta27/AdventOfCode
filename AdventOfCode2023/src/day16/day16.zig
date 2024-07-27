const std = @import("std");
const print = std.debug.print;

const Direction = enum(u2) { up = 0, right = 1, down = 2, left = 3 };

const VERTICAL_SPLITTER = '|';
const HORIZONTAL_SPLITTER = '-';

const EMPTY = '.';
const RIGHT_MIRROR = '/';

const LEFT_MIRROR = '\\';

const Beam = struct {
    x: usize,
    y: usize,

    isActive: bool,

    direction: Direction,
};

fn encode_coord(x: usize, y: usize) u128 {
    return @as(u128, x) << 64 | @as(u128, y);
}

fn encode_coord_with_direction(x: usize, y: usize, direction: Direction) u130 {
    return @as(u130, x) << 66 | @as(u130, y) << 2 | @intFromEnum(direction);
}

fn tiles_covered(allocator: std.mem.Allocator, input: [][]const u8, initial_beam: *Beam) !usize {
    var beams = std.ArrayList(*Beam).init(allocator);

    try beams.append(initial_beam);

    var tile_set = std.AutoHashMap(u128, bool).init(allocator);
    try tile_set.put(encode_coord(initial_beam.x, initial_beam.y), true);

    var coord_direction_set = std.AutoHashMap(u130, bool).init(allocator);

    while (beams.items.len > 0) {
        const owned_beams = try beams.toOwnedSlice();
        beams = std.ArrayList(*Beam).init(allocator);

        for (owned_beams) |beam| {
            if (!beam.isActive) {
                continue;
            }

            const encoded_coord = encode_coord_with_direction(beam.x, beam.y, beam.direction);

            if (coord_direction_set.get(encoded_coord)) |_| {
                continue;
            }

            try coord_direction_set.put(encoded_coord, true);
            try beams.append(beam);

            switch (input[beam.y][beam.x]) {
                RIGHT_MIRROR => {
                    switch (beam.direction) {
                        Direction.up => beam.*.direction = Direction.right,
                        Direction.right => beam.*.direction = Direction.up,
                        Direction.down => beam.*.direction = Direction.left,
                        Direction.left => beam.*.direction = Direction.down,
                    }
                },
                LEFT_MIRROR => {
                    switch (beam.direction) {
                        Direction.up => beam.*.direction = Direction.left,
                        Direction.right => beam.*.direction = Direction.down,
                        Direction.down => beam.*.direction = Direction.right,
                        Direction.left => beam.*.direction = Direction.up,
                    }
                },
                VERTICAL_SPLITTER => {
                    switch (beam.direction) {
                        Direction.left, Direction.right => {
                            beam.*.direction = Direction.up;

                            const new_beam = try allocator.create(Beam);
                            new_beam.*.x = beam.x;
                            new_beam.*.y = beam.y;
                            new_beam.*.isActive = true;
                            new_beam.*.direction = Direction.down;

                            try beams.append(new_beam);
                        },
                        else => {},
                    }
                },
                HORIZONTAL_SPLITTER => {
                    switch (beam.direction) {
                        Direction.up, Direction.down => {
                            beam.*.direction = Direction.right;

                            const new_beam = try allocator.create(Beam);
                            new_beam.*.x = beam.x;
                            new_beam.*.y = beam.y;
                            new_beam.*.isActive = true;
                            new_beam.*.direction = Direction.left;

                            try beams.append(new_beam);
                        },
                        else => {},
                    }
                },
                else => {},
            }

            switch (beam.direction) {
                Direction.up => {
                    if (beam.y == 0) {
                        beam.*.isActive = false;
                        continue;
                    }

                    beam.*.y -= 1;
                },
                Direction.right => {
                    if (beam.x == input[0].len - 1) {
                        beam.*.isActive = false;
                        continue;
                    }

                    beam.*.x += 1;
                },
                Direction.down => {
                    if (beam.y == input.len - 1) {
                        beam.*.isActive = false;
                        continue;
                    }

                    beam.*.y += 1;
                },
                Direction.left => {
                    if (beam.*.x == 0) {
                        beam.*.isActive = false;
                        continue;
                    }

                    beam.*.x -= 1;
                },
            }

            try tile_set.put(encode_coord(beam.x, beam.y), true);
        }
    }

    return tile_set.count();
}

pub fn solve(input: [][]const u8) !void {
    const allocator = std.heap.page_allocator;

    var top_left_right = Beam{ .x = 0, .y = 0, .isActive = true, .direction = Direction.right };

    const part1 = try tiles_covered(allocator, input, &top_left_right);
    print("Part 1: {}\n", .{part1});

    var starting_points = std.ArrayList(*Beam).init(allocator);

    var top_left_down = Beam{ .x = 0, .y = 0, .isActive = true, .direction = Direction.down };

    var top_right_down = Beam{ .x = input[0].len - 1, .y = 0, .isActive = true, .direction = Direction.down };
    var top_right_left = Beam{ .x = input[0].len - 1, .y = 0, .isActive = true, .direction = Direction.left };

    var bottom_left_right = Beam{ .x = 0, .y = input.len - 1, .isActive = true, .direction = Direction.right };
    var bottom_left_up = Beam{ .x = 0, .y = input.len - 1, .isActive = true, .direction = Direction.up };

    var bottom_right_left = Beam{ .x = input[0].len - 1, .y = input.len - 1, .isActive = true, .direction = Direction.left };
    var bottom_right_up = Beam{ .x = input[0].len - 1, .y = input.len - 1, .isActive = true, .direction = Direction.up };

    try starting_points.append(&top_left_right);
    try starting_points.append(&top_left_down);

    try starting_points.append(&top_right_down);
    try starting_points.append(&top_right_left);

    try starting_points.append(&bottom_left_right);
    try starting_points.append(&bottom_left_up);

    try starting_points.append(&bottom_right_left);
    try starting_points.append(&bottom_right_up);

    for (1..input.len) |y| {
        var r = try allocator.create(Beam);
        r.x = 0;
        r.y = y;
        r.isActive = true;
        r.direction = Direction.right;

        var l = try allocator.create(Beam);
        l.x = input[0].len - 1;
        l.y = y;
        l.isActive = true;
        l.direction = Direction.left;

        try starting_points.append(l);
        try starting_points.append(r);
    }

    for (1..input[0].len) |x| {
        var d = try allocator.create(Beam);
        d.x = x;
        d.y = 0;
        d.isActive = true;
        d.direction = Direction.down;

        var u = try allocator.create(Beam);
        u.x = x;
        u.y = input.len - 1;
        u.isActive = true;
        u.direction = Direction.up;

        try starting_points.append(d);
        try starting_points.append(u);
    }

    var highest: usize = 0;
    for (try starting_points.toOwnedSlice()) |starting| {
        const covered = try tiles_covered(allocator, input, starting);

        if (covered > highest) {
            highest = covered;
        }
    }

    print("Part 2: {}\n", .{highest});
}
