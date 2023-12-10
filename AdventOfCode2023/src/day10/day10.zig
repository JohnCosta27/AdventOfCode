const std = @import("std");
const print = std.debug.print;

const VERTICAL = '|';
const HORIZONTAL = '-';
const NORTH_EAST = 'L';
const NORTH_WEST = 'J';
const SOUTH_EAST = 'F';
const SOUTH_WEST = '7';
const EMPTY = '.';
const START = 'S';

const Direction = enum { up, down, right, left };

fn isRightPointing(c: u8) bool {
    return c == HORIZONTAL or c == NORTH_EAST or c == SOUTH_EAST;
}
fn isLeftPoiting(c: u8) bool {
    return c == HORIZONTAL or c == NORTH_WEST or c == SOUTH_WEST;
}
fn isUpPointing(c: u8) bool {
    return c == VERTICAL or c == NORTH_EAST or c == NORTH_WEST;
}
fn isDownPointing(c: u8) bool {
    return c == VERTICAL or c == SOUTH_WEST or c == SOUTH_EAST;
}

const Grid = struct {
    grid: [][]u8,
    x: usize,
    y: usize,

    lastDirection: Direction,

    // ONLY CALL AT VERY BEGINNING
    pub fn findStart(self: Grid) u8 {
        var current = self.grid[self.y][self.x];

        var up = self.grid[self.y - 1][self.x];
        var down = self.grid[self.y + 1][self.x];
        var left = self.grid[self.y][self.x - 1];
        var right = self.grid[self.y][self.x + 1];

        if (up == VERTICAL and down == VERTICAL) {
            // |
            current = VERTICAL;
        } else if (left == HORIZONTAL and right == HORIZONTAL) {
            current = HORIZONTAL;
        } else if (isRightPointing(left) and isDownPointing(up)) {
            // NORTH_WEST == J
            current = NORTH_WEST;
        } else if (isLeftPoiting(right) and isDownPointing(up)) {
            // NORTH_EAST = L
            current = NORTH_EAST;
        } else if (isRightPointing(left) and isUpPointing(down)) {
            // SOUTH_WEST
            current = SOUTH_WEST;
        } else if (isLeftPoiting(right) and isUpPointing(down)) {
            // SOUTH_EAST
            current = SOUTH_EAST;
        }

        return current;
    }

    pub fn walk(_self: *Grid, map: *std.AutoHashMap(u128, usize)) !void {
        var self = _self.*;

        var encoding: u128 = @as(u128, self.x) << 64 | @as(u128, self.y);
        try map.*.put(encoding, 1);

        var current = self.grid[self.y][self.x];

        if (current == START) {
            current = self.findStart();
        }

        if (current == VERTICAL) {
            // up or down valid.
            if (self.lastDirection == Direction.up) {
                _self.*.y = self.y + 1;
            } else {
                _self.*.y = self.y - 1;
            }
            return;
        } else if (current == HORIZONTAL) {
            // left or right valid
            if (self.lastDirection == Direction.left) {
                _self.*.x = self.x + 1;
            } else {
                _self.*.x = self.x - 1;
            }
            return;
        } else if (current == NORTH_EAST) {
            // up or right valid
            if (self.lastDirection == Direction.up) {
                _self.*.x = self.x + 1;
                _self.*.lastDirection = Direction.left;
            } else {
                _self.*.y = self.y - 1;
                _self.*.lastDirection = Direction.down;
            }
            return;
        } else if (current == NORTH_WEST) {
            // up  or left valid
            if (self.lastDirection == Direction.up) {
                _self.*.x = self.x - 1;
                _self.*.lastDirection = Direction.right;
            } else {
                _self.*.y = self.y - 1;
                _self.*.lastDirection = Direction.down;
            }
            return;
        } else if (current == SOUTH_EAST) {
            // down or right valid
            if (self.lastDirection == Direction.down) {
                _self.*.x = self.x + 1;
                _self.*.lastDirection = Direction.left;
            } else {
                _self.*.y = self.y + 1;
                _self.*.lastDirection = Direction.up;
            }
            return;
        } else if (current == SOUTH_WEST) {
            // down or left valid
            if (self.lastDirection == Direction.down) {
                _self.*.x = self.x - 1;
                _self.*.lastDirection = Direction.right;
            } else {
                _self.*.y = self.y + 1;
                _self.*.lastDirection = Direction.up;
            }
            return;
        }
    }
};

fn initZeroes(line: *[]u8) void {
    var l = line.*;
    for (0..l.len) |i| {
        l[i] = EMPTY;
    }
}

fn createGrid(allocator: std.mem.Allocator, input: [][]const u8) !(*Grid) {
    var gridRows = try allocator.alloc([]u8, input.len + 2);

    var x: usize = 0;
    var y: usize = 0;

    for (0..gridRows.len) |i| {
        gridRows[i] = try allocator.alloc(u8, input[0].len + 2);

        gridRows[i][0] = EMPTY;
        gridRows[i][input[0].len + 1] = EMPTY;

        if (i == 0 or i == gridRows.len - 1) {
            initZeroes(&gridRows[i]);
            continue;
        }

        var index: usize = 1;
        for (input[i - 1], 1..) |c, k| {
            if (c == START) {
                y = i;
                x = k;
            }

            gridRows[i][index] = c;
            index += 1;
        }
    }

    var grid = Grid{ .grid = gridRows, .x = x, .y = y, .lastDirection = Direction.left };
    return &grid;
}

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;
    var _grid = try createGrid(allocator, input);

    var grid = _grid.*;

    var map = std.AutoHashMap(u128, usize).init(allocator);
    defer map.deinit();

    var start = grid.findStart();
    var firstGo = Direction.up;
    var secondGo = Direction.down;

    grid.grid[grid.y][grid.x] = start;

    if (start == VERTICAL) {
        // up or down valid.
        firstGo = Direction.up;
        secondGo = Direction.down;
    } else if (start == HORIZONTAL) {
        // horizonal;
        firstGo = Direction.left;
        secondGo = Direction.right;
    } else if (start == NORTH_EAST) {
        // up or right valid
        firstGo = Direction.up;
        secondGo = Direction.right;
    } else if (start == NORTH_WEST) {
        // up  or left valid
        firstGo = Direction.up;
        secondGo = Direction.left;
    } else if (start == SOUTH_EAST) {
        // down or right valid
        firstGo = Direction.down;
        secondGo = Direction.right;
    } else if (start == SOUTH_WEST) {
        // down or left valid
        firstGo = Direction.down;
        secondGo = Direction.left;
    }

    grid.lastDirection = firstGo;

    var startX = grid.x;
    var startY = grid.y;
    var part1: usize = 1;

    try grid.walk(&map);
    while (grid.x != startX or grid.y != startY) {
        try grid.walk(&map);
        part1 += 1;
    }

    var encoding: u128 = @as(u128, grid.x) << 64 | @as(u128, grid.y);
    try map.put(encoding, 1);

    var part2: usize = 0;

    for (0..grid.grid.len) |i| {
        for (0..grid.grid[0].len) |j| {
            if (grid.grid[i][j] != EMPTY) {
                var e: u128 = @as(u128, j) << 64 | @as(u128, i);
                if (map.get(e)) |_| {
                    continue;
                }
            }
            //F
            //||.

            // Count number of various things
            // || = Outside loop, we want an odd number
            // LJ = Outside loop, we want north's to not pair up
            // F7 = outisde loop.

            var verticalCounter: usize = 0;

            var lastChar: u8 = EMPTY;

            for (0..j) |k| {
                var e: u128 = @as(u128, k) << 64 | @as(u128, i);
                if (map.get(e)) |_| {
                    // print("Checking: {},{}\n", .{ i, k });
                    var a = grid.grid[i][k];
                    if (a == VERTICAL) {
                        // print("Incrementing vertical\n", .{});
                        verticalCounter += 1;
                    } else if (a == NORTH_EAST) {
                        // L7
                        // if (lastChar == SOUTH_WEST) {
                        //     print("1\n", .{});
                        //     verticalCounter += 1;
                        // }
                    } else if (a == NORTH_WEST) {
                        // FJ
                        if (lastChar == SOUTH_EAST) {
                            verticalCounter += 1;
                        }
                    } else if (a == SOUTH_EAST) {
                        // if (lastChar == NORTH_WEST) {
                        //     print("3\n", .{});
                        //     verticalCounter += 1;
                        // }
                    } else if (a == SOUTH_WEST) {
                        if (lastChar == NORTH_EAST) {
                            verticalCounter += 1;
                        }
                    }
                }
                if (grid.grid[i][k] != HORIZONTAL) {
                    lastChar = grid.grid[i][k];
                }
            }

            if (verticalCounter % 2 == 1) {
                // print("Adding: {},{} | With: {}\n", .{ i, j, verticalCounter });
                part2 += 1;
            }
        }
    }

    print("Part 1: {}\n", .{part1 / 2});
    print("Part 2: {}\n", .{part2});
}
