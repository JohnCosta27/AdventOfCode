const std = @import("std");

const Rgb = struct {
    red: usize,
    green: usize,
    blue: usize,
};

pub fn solve(input: [][]const u8) !void {
    const dices = Rgb{ .red = 12, .green = 13, .blue = 14 };
    var part1: usize = 0;
    var part2: usize = 0;

    for (input) |line| {
        var splitIter = std.mem.splitSequence(u8, line, ": ");

        var game = splitIter.next().?;
        var gameInput = splitIter.next().?;
        var gameNum = try std.fmt.parseInt(usize, game[5..], 10);

        var gameSteps = std.mem.splitSequence(u8, gameInput, "; ");
        var part1Count = true;

        var highestDice = Rgb{ .red = 0, .green = 0, .blue = 0 };

        while (gameSteps.next()) |step| {
            var singleDice = std.mem.tokenizeAny(u8, step, ", ");
            var stepDices = Rgb{ .red = 0, .green = 0, .blue = 0 };

            while (singleDice.next()) |dice| {
                var diceNum = try std.fmt.parseInt(usize, dice, 10);
                var colour = singleDice.next().?;
                if (std.mem.eql(u8, colour, "red")) {
                    stepDices.red = diceNum;
                } else if (std.mem.eql(u8, colour, "green")) {
                    stepDices.green = diceNum;
                } else if (std.mem.eql(u8, colour, "blue")) {
                    stepDices.blue = diceNum;
                }
            }

            if (part1Count and !(stepDices.red <= dices.red and stepDices.green <= dices.green and stepDices.blue <= dices.blue)) {
                part1Count = false;
            }

            if (highestDice.red < stepDices.red) {
                highestDice.red = stepDices.red;
            }
            if (highestDice.green < stepDices.green) {
                highestDice.green = stepDices.green;
            }
            if (highestDice.blue < stepDices.blue) {
                highestDice.blue = stepDices.blue;
            }
        }

        if (part1Count) {
            part1 += gameNum;
        }

        part2 += highestDice.red * highestDice.green * highestDice.blue;
    }

    std.debug.print("Part 1: {}\n", .{part1});
    std.debug.print("Part 2: {}\n", .{part2});
}
