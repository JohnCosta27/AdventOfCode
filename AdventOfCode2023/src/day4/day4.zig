const std = @import("std");
const print = std.debug.print;

pub fn solve(input: [][]const u8) !void {
    var part1: u32 = 0;
    const allocator = std.heap.page_allocator;

    for (input) |line| {
        var verticalVarSplit = std.mem.tokenizeSequence(u8, line, "|");

        var myMap = std.AutoHashMap(u32, u32).init(allocator);

        var winningNums = verticalVarSplit.next().?;
        var myNums = verticalVarSplit.next().?;

        var currentScore: u32 = 0;

        // Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53

        var spaceTokeniser = std.mem.tokenizeAny(u8, winningNums, " :");
        _ = spaceTokeniser.next().?;
        _ = spaceTokeniser.next().?;

        while (spaceTokeniser.next()) |num| {
            if (num.len > 0) {
                try myMap.put(try std.fmt.parseInt(u32, num, 10), 1);
            }
        }

        spaceTokeniser = std.mem.tokenizeAny(u8, myNums, " ");

        while (spaceTokeniser.next()) |num| {
            if (num.len > 0) {
                var winningNum = try std.fmt.parseInt(u32, num, 10);
                if (myMap.get(winningNum)) |_| {
                    if (currentScore == 0) {
                        currentScore = 1;
                    } else {
                        currentScore += currentScore;
                    }
                }
            }
        }

        part1 += currentScore;
        myMap.deinit();
    }

    var gamesProcessing = std.AutoHashMap(usize, u32).init(allocator);

    var part2: u32 = 0;

    for (input, 0..) |_, index| {
        try gamesProcessing.put(index, 1);
        part2 += 1;
    }

    var counter: usize = 0;

    while (counter < 5) {
        counter += 1;
        var gamesPlayed = false;

        for (1..input.len + 1) |gameIndex| {
            var numOfGames = gamesProcessing.get(gameIndex);
            // print("Game: {} | Num Of Games {?} \n", .{ gameIndex, numOfGames });

            if (numOfGames) |i| {
                if (i == 0) {
                    continue;
                }
            } else {
                continue;
            }
            gamesPlayed = true;

            var line = input[gameIndex - 1];
            var verticalVarSplit = std.mem.tokenizeSequence(u8, line, "|");

            var myMap = std.AutoHashMap(u32, u32).init(allocator);

            var winningNums = verticalVarSplit.next().?;
            var myNums = verticalVarSplit.next().?;

            var spaceTokeniser = std.mem.tokenizeAny(u8, winningNums, " :");
            _ = spaceTokeniser.next().?;
            _ = spaceTokeniser.next().?;

            while (spaceTokeniser.next()) |num| {
                if (num.len > 0) {
                    try myMap.put(try std.fmt.parseInt(u32, num, 10), 1);
                }
            }

            spaceTokeniser = std.mem.tokenizeAny(u8, myNums, " ");
            var numbersWon: u32 = 0;

            while (spaceTokeniser.next()) |num| {
                if (num.len > 0) {
                    var winningNum = try std.fmt.parseInt(u32, num, 10);
                    if (myMap.get(winningNum)) |_| {
                        numbersWon += 1;
                    }
                }
            }

            if (numbersWon == 0) {
                continue;
            }

            // print("Adding: \n", .{});
            for (gameIndex + 1..gameIndex + 1 + numbersWon) |i| {
                // print("{}, ", .{i});
                var currentNums: u32 = 0;
                if (gamesProcessing.get(i)) |n| {
                    currentNums = n;
                }
                try gamesProcessing.put(i, numOfGames.? + currentNums);
                part2 += numOfGames.?;
            }
            // print("\n", .{});
            myMap.deinit();

            try gamesProcessing.put(gameIndex, 0);
        }

        if (!gamesPlayed) {
            break;
        }
    }

    for (input, 0..) |line, index| {
        _ = line;
        _ = index;
    }

    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});
}
