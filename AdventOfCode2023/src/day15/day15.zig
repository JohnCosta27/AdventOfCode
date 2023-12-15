const std = @import("std");
const print = std.debug.print;

const Lens = struct { label: []const u8, focalLength: u8 };

fn hash(string: []const u8) u8 {
    var hashValue: u32 = 0;
    for (string) |c| {
        hashValue += c;
        hashValue *= 17;
        hashValue %= 256;
    }
    return @truncate(hashValue);
}

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;
    var line = input[0];

    var part1: usize = 0;
    var part2: usize = 0;

    var boxes = try allocator.alloc(std.ArrayList(Lens), 256);
    for (0..boxes.len) |i| {
        var arrList = std.ArrayList(Lens).init(allocator);
        boxes[i] = arrList;
    }

    var tokenizer = std.mem.tokenizeSequence(u8, line, ",");
    while (tokenizer.next()) |v| {
        part1 += hash(v);

        if (v[v.len - 1] == '-') {
            // remove.
            var label = v[0 .. v.len - 1];
            var index = @as(usize, hash(label));
            var list = &boxes[index];
            for (list.items, 0..) |box, i| {
                if (std.mem.eql(u8, box.label, label)) {
                    _ = list.*.orderedRemove(i);
                    break;
                }
            }
        } else {
            // add, remove last 2 characters
            var label = v[0 .. v.len - 2];
            var focalLength = try std.fmt.parseInt(u8, v[v.len - 1 ..], 10);
            var index = @as(usize, hash(label));
            var list = &boxes[index];

            var exists = false;
            for (0..list.items.len) |i| {
                if (std.mem.eql(u8, list.items[i].label, label)) {
                    exists = true;
                    list.items[i].focalLength = focalLength;
                    break;
                }
            }

            if (!exists) {
                try list.*.append(.{ .focalLength = focalLength, .label = label });
            }
        }
    }

    for (boxes, 1..) |box, boxIndex| {
        for (box.items, 1..) |lens, slot| {
            part2 += boxIndex * slot * @as(usize, lens.focalLength);
        }
    }

    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});
}
