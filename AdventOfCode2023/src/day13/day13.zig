const std = @import("std");

const print = std.debug.print;

fn get_grid_col(allocator: std.mem.Allocator, input: [][]u8, colIndex: usize) ![]u8 {
    var col = try allocator.alloc(u8, input.len);

    for (input, 0..) |line, index| {
        col[index] = line[colIndex];
    }

    return col;
}

fn single_tile(allocator: std.mem.Allocator, input: [][]u8, part1val: usize) !usize {
    var ok = true;
    var index_found: usize = 0;

    for (0..input.len - 1) |index| {
        var down_counter: usize = index;
        var up_counter: usize = index + 1;

        ok = true;

        while (down_counter >= 0 and up_counter < input.len) {
            if (!std.mem.eql(u8, input[down_counter], input[up_counter])) {
                ok = false;
                break;
            }

            if (down_counter == 0) {
                break;
            }

            down_counter -= 1;
            up_counter += 1;
        }

        if (ok and (index + 1) * 100 != part1val) {
            index_found = index;
            break;
        } else {
            ok = false;
        }
    }

    if (ok) {
        // horizon found
        return (index_found + 1) * 100;
    }

    ok = true;
    index_found = 0;

    for (0..input[0].len - 1) |index| {
        var down_counter: usize = index;
        var up_counter: usize = index + 1;

        ok = true;

        while (down_counter >= 0 and up_counter < input[0].len) {
            var col1 = try get_grid_col(allocator, input, down_counter);
            var col2 = try get_grid_col(allocator, input, up_counter);

            defer allocator.free(col1);
            defer allocator.free(col2);

            if (!std.mem.eql(u8, col1, col2)) {
                ok = false;
                break;
            }

            if (down_counter == 0) {
                break;
            }

            down_counter -= 1;
            up_counter += 1;
        }

        if (ok and index + 1 != part1val) {
            index_found = index;
            break;
        } else {
            ok = false;
        }
    }

    if (ok) {
        return index_found + 1;
    }

    return 0;
}

pub fn solve(input: [][]u8) !void {
    var start_pointer: usize = 0;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    var counter: usize = 0;
    var part1_results = try allocator.alloc(usize, 1000);

    var part1: usize = 0;
    var part2: usize = 0;

    for (input, 0..) |line, index| {
        if (line.len == 0) {
            // found our empty line.
            var num = try single_tile(allocator, input[start_pointer..index], 0);

            part1_results[counter] = num;

            part1 += num;
            start_pointer = index + 1;
            counter += 1;
        }
    }

    start_pointer = 0;
    counter = 0;

    for (input, 0..) |line, index| {
        if (line.len == 0) {
            // found our empty line.

            var temp: u8 = 0;

            topLoop: for (start_pointer..index) |i| {
                for (0..input[start_pointer].len) |j| {
                    temp = input[i][j];
                    if (input[i][j] == '.') {
                        temp = '.';
                        input[i][j] = '#';
                    } else {
                        temp = '#';
                        input[i][j] = '.';
                    }

                    var num = try single_tile(allocator, input[start_pointer..index], part1_results[counter]);

                    input[i][j] = temp;

                    if (num == 0) {
                        continue;
                    }

                    part2 += num;
                    break :topLoop;
                }
            }

            start_pointer = index + 1;
            counter += 1;
        }
    }

    // 28996 tried

    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});
}
