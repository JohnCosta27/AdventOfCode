const std = @import("std");
const mem = std.mem;
const ArrayList = std.ArrayList;

pub fn solve(input: [][]const u8) !void {
    var part1: usize = 0;

    for (input) |line| {
        var firstDigit: usize = 0;
        for (line) |char| {
            if (char >= '0' and char <= '9') {
                firstDigit = char - '0';
                break;
            }
        }

        var lastDigit: usize = 0;
        for (line) |char| {
            if (char >= '0' and char <= '9') {
                lastDigit = char - '0';
            }
        }

        part1 += firstDigit * 10 + lastDigit;
    }

    std.debug.print("Part 1: {}\n", .{part1});

    var part2: usize = 0;

    for (input) |line| {
        var firstDigit: usize = 0;
        var index: usize = 0;

        for (line) |char| {
            if (char >= '0' and char <= '9') {
                firstDigit = char - '0';
                break;
            }
            index += 1;
        }

        if (std.mem.indexOf(u8, line, "one")) |position| {
            if (position < index) {
                index = position;
                firstDigit = 1;
            }
        }
        if (std.mem.indexOf(u8, line, "two")) |position| {
            if (position < index) {
                index = position;
                firstDigit = 2;
            }
        }
        if (std.mem.indexOf(u8, line, "three")) |position| {
            if (position < index) {
                index = position;
                firstDigit = 3;
            }
        }
        if (std.mem.indexOf(u8, line, "four")) |position| {
            if (position < index) {
                index = position;
                firstDigit = 4;
            }
        }
        if (std.mem.indexOf(u8, line, "five")) |position| {
            if (position < index) {
                index = position;
                firstDigit = 5;
            }
        }
        if (std.mem.indexOf(u8, line, "six")) |position| {
            if (position < index) {
                index = position;
                firstDigit = 6;
            }
        }
        if (std.mem.indexOf(u8, line, "seven")) |position| {
            if (position < index) {
                index = position;
                firstDigit = 7;
            }
        }
        if (std.mem.indexOf(u8, line, "eight")) |position| {
            if (position < index) {
                index = position;
                firstDigit = 8;
            }
        }
        if (std.mem.indexOf(u8, line, "nine")) |position| {
            if (position < index) {
                index = position;
                firstDigit = 9;
            }
        }

        var lastDigit: usize = 0;
        var currentIndex: usize = 0;
        var indexLast: usize = 0;
        for (line) |char| {
            if (char >= '0' and char <= '9') {
                lastDigit = char - '0';
                indexLast = currentIndex;
            }
            currentIndex += 1;
        }

        if (std.mem.lastIndexOf(u8, line, "one")) |position| {
            if (position > indexLast) {
                indexLast = position;
                lastDigit = 1;
            }
        }
        if (std.mem.lastIndexOf(u8, line, "two")) |position| {
            if (position > indexLast) {
                indexLast = position;
                lastDigit = 2;
            }
        }
        if (std.mem.lastIndexOf(u8, line, "three")) |position| {
            if (position > indexLast) {
                indexLast = position;
                lastDigit = 3;
            }
        }
        if (std.mem.lastIndexOf(u8, line, "four")) |position| {
            if (position > indexLast) {
                indexLast = position;
                lastDigit = 4;
            }
        }
        if (std.mem.lastIndexOf(u8, line, "five")) |position| {
            if (position > indexLast) {
                indexLast = position;
                lastDigit = 5;
            }
        }
        if (std.mem.lastIndexOf(u8, line, "six")) |position| {
            if (position > indexLast) {
                indexLast = position;
                lastDigit = 6;
            }
        }
        if (std.mem.lastIndexOf(u8, line, "seven")) |position| {
            if (position > indexLast) {
                indexLast = position;
                lastDigit = 7;
            }
        }
        if (std.mem.lastIndexOf(u8, line, "eight")) |position| {
            if (position > indexLast) {
                indexLast = position;
                lastDigit = 8;
            }
        }
        if (std.mem.lastIndexOf(u8, line, "nine")) |position| {
            if (position > indexLast) {
                indexLast = position;
                lastDigit = 9;
            }
        }

        part2 += firstDigit * 10 + lastDigit;
    }

    std.debug.print("Part 2: {}\n", .{part2});
}
