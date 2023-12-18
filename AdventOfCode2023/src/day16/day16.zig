const std = @import("std");
const print = std.debug.print;

const EMPTY = '.';
const VERTICAL_SPLIT = '|';
const HORIZONTAL_SPLIT = '-';
const CLOCKWISE_TURN = '/';
const ANTI_CLOCKWISE_TURN = '\\';

const Directions = enum { UP, DOWN, LEFT, RIGHT };

const BeamsController = struct {
    beams: std.AutoHashMap(usize, *Beam),
    allocator: std.mem.Allocator,
    counter: usize,
    heatmap: std.AutoHashMap(u128, bool),
    splitsMade: std.AutoHashMap(u128, bool),

    pub fn walk(self: *BeamsController) !void {
        var iter = self.*.beams.iterator();
        var deleteList = std.ArrayList(usize).init(self.allocator);
        defer deleteList.deinit();

        while (iter.next()) |entry| {
            var delete = try entry.value_ptr.*.step();
            if (delete) {
                // print("Beam {} removing\n", .{entry.value_ptr.*.index});
                try deleteList.append(entry.key_ptr.*);
                // self.allocator.destroy(entry.value_ptr.*);
            } else {
                // var beams = entry.value_ptr.*;
                // print("Beam {} ({},{}) {}\n", .{ beams.index, beams.x, beams.y, beams.direction });
            }
        }

        for (deleteList.items) |i| {
            _ = self.*.beams.remove(i);
        }
    }

    pub fn horizontalSplit(self: *BeamsController, beam: *Beam) !bool {
        // Assume direction is up or down.
        // Assume "parent" beam always goes right.

        var coord = @as(u128, beam.x) << 64 | @as(u128, beam.y);
        if (self.*.splitsMade.get(coord)) |_| {
            // dont split again
            return true;
        }

        var splitBeam = try self.allocator.create(Beam);
        splitBeam.*.grid = beam.*.grid;
        splitBeam.*.x = beam.*.x;
        splitBeam.*.y = beam.*.y;
        splitBeam.*.direction = Directions.LEFT;
        splitBeam.*.controller = beam.*.controller;

        self.*.counter += 1;
        splitBeam.*.index = self.*.counter;

        try self.*.beams.put(splitBeam.index, splitBeam);
        try self.*.splitsMade.put(coord, true);

        return false;
    }

    pub fn verticalSplit(self: *BeamsController, beam: *Beam) !bool {
        // Assume direction is left or right
        // Assume "parent" beam always goes down.

        var coord = @as(u128, beam.x) << 64 | @as(u128, beam.y);
        if (self.*.splitsMade.get(coord)) |_| {
            // dont split again
            return true;
        }

        var splitBeam = try self.allocator.create(Beam);
        splitBeam.*.grid = beam.*.grid;
        splitBeam.*.x = beam.*.x;
        splitBeam.*.y = beam.*.y;
        splitBeam.*.direction = Directions.UP;
        splitBeam.*.controller = beam.*.controller;

        self.*.counter += 1;
        splitBeam.*.index = self.*.counter;

        try self.*.beams.put(splitBeam.index, splitBeam);
        try self.*.splitsMade.put(coord, true);

        return false;
    }
};

const Beam = struct {
    grid: *[][]const u8,
    x: usize,
    y: usize,
    direction: Directions,
    controller: *BeamsController,
    index: usize,

    pub fn step(self: *Beam) !bool {
        var coord = @as(u128, self.x) << 64 | @as(u128, self.y);
        try self.*.controller.heatmap.put(coord, true);
        switch (self.direction) {
            Directions.RIGHT => {
                if (self.*.x == self.*.grid.*[0].len - 1) {
                    return true;
                }

                var tile = self.*.grid.*[self.*.y][self.*.x];
                if (tile == VERTICAL_SPLIT) {
                    // call beams controller vertical split.
                    var alreadyDone = try self.controller.verticalSplit(self);
                    if (alreadyDone) {
                        return true;
                    }
                    self.*.direction = Directions.DOWN;
                } else if (tile == CLOCKWISE_TURN) {
                    // moving right. turn upwards.
                    self.*.direction = Directions.UP;
                } else if (tile == ANTI_CLOCKWISE_TURN) {
                    self.*.direction = Directions.DOWN;
                }
            },
            Directions.LEFT => {
                if (self.*.x == 0) {
                    return true;
                }

                var tile = self.*.grid.*[self.*.y][self.*.x];
                if (tile == VERTICAL_SPLIT) {
                    // call beams controller vertical split.
                    var alreadyDone = try self.controller.verticalSplit(self);
                    if (alreadyDone) {
                        return true;
                    }
                    self.*.direction = Directions.DOWN;
                } else if (tile == CLOCKWISE_TURN) {
                    // moving right. turn upwards.
                    self.*.direction = Directions.DOWN;
                } else if (tile == ANTI_CLOCKWISE_TURN) {
                    self.*.direction = Directions.UP;
                }
            },
            Directions.UP => {
                if (self.*.y == 0) {
                    return true;
                }

                var tile = self.*.grid.*[self.*.y][self.*.x];
                if (tile == HORIZONTAL_SPLIT) {
                    // call beams controller vertical split.
                    var alreadyDone = try self.controller.horizontalSplit(self);
                    if (alreadyDone) {
                        return true;
                    }
                    self.*.direction = Directions.RIGHT;
                } else if (tile == CLOCKWISE_TURN) {
                    // moving right. turn upwards.
                    self.*.direction = Directions.RIGHT;
                } else if (tile == ANTI_CLOCKWISE_TURN) {
                    self.*.direction = Directions.LEFT;
                }
            },
            Directions.DOWN => {
                if (self.*.y == self.*.grid.*.len - 1) {
                    return true;
                }

                var tile = self.*.grid.*[self.*.y][self.*.x];
                if (tile == HORIZONTAL_SPLIT) {
                    // call beams controller vertical split.
                    var alreadyDone = try self.controller.horizontalSplit(self);
                    if (alreadyDone) {
                        return true;
                    }
                    self.*.direction = Directions.RIGHT;
                } else if (tile == CLOCKWISE_TURN) {
                    // moving right. turn upwards.
                    self.*.direction = Directions.LEFT;
                } else if (tile == ANTI_CLOCKWISE_TURN) {
                    self.*.direction = Directions.RIGHT;
                }
            },
        }

        switch (self.direction) {
            Directions.UP => {
                self.*.y -= 1;
            },
            Directions.DOWN => {
                self.*.y += 1;
            },
            Directions.LEFT => {
                self.*.x -= 1;
            },
            Directions.RIGHT => {
                self.*.x += 1;
            },
        }

        coord = @as(u128, self.x) << 64 | @as(u128, self.y);
        try self.*.controller.heatmap.put(coord, true);

        return false;
    }
};

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;
    var controller = BeamsController{ .allocator = allocator, .beams = std.AutoHashMap(usize, *Beam).init(allocator), .counter = 0, .heatmap = std.AutoHashMap(u128, bool).init(allocator), .splitsMade = std.AutoHashMap(u128, bool).init(allocator) };

    var in = input;

    var firstBeam = try allocator.create(Beam);
    firstBeam.*.x = 0;
    firstBeam.*.y = 0;
    firstBeam.*.direction = Directions.RIGHT;
    firstBeam.*.grid = &in;
    firstBeam.*.controller = &controller;
    firstBeam.*.index = 0;

    try controller.beams.put(0, firstBeam);

    while (controller.beams.count() > 0) {
        try controller.walk();
    }

    var iter = controller.heatmap.iterator();
    while (iter.next()) |entry| {
        var x = entry.key_ptr.* >> 64;
        var y = entry.key_ptr.* & 0xFFFFFFFFFFFFFFFF;
        print("{},{}\n", .{ x, y });
    }

    print("Part 1: {}\n", .{controller.heatmap.count()});
}
// 6858
