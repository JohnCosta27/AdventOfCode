const std = @import("std");
const utils = @import("./utils.zig");

const InstructionType = enum { LITERAL, REASSIGN, NOT, AND, HACKY_AND, OR, LSHIFT, RSHIFT };

const Instruction = struct {
    type: InstructionType,

    // To be used with LITERAL
    num: ?u16,

    firstLetter: ?[]const u8,
    secondLetter: ?[]const u8,
};

fn getOp(op: []const u8) InstructionType {
    if (std.mem.eql(u8, op, "AND")) {
        return InstructionType.AND;
    }
    if (std.mem.eql(u8, op, "OR")) {
        return InstructionType.OR;
    }
    if (std.mem.eql(u8, op, "LSHIFT")) {
        return InstructionType.LSHIFT;
    }
    if (std.mem.eql(u8, op, "RSHIFT")) {
        return InstructionType.RSHIFT;
    }

    unreachable;
}

fn getLetter(map: std.StringHashMap(Instruction), cache: *std.StringHashMap(u16), letter: []const u8) !u16 {
    if (cache.contains(letter)) {
        return cache.*.get(letter).?;
    }

    var op = map.get(letter).?;

    if (op.type == InstructionType.LITERAL) {
        try cache.*.put(letter, op.num.?);
        return op.num.?;
    }

    if (op.type == InstructionType.NOT) {
        var notRes = ~(try getLetter(map, cache, op.firstLetter.?));
        try cache.*.put(letter, notRes);
        return notRes;
    }

    if (op.type == InstructionType.REASSIGN) {
        var reassignRes = try getLetter(map, cache, op.firstLetter.?);
        try cache.*.put(letter, reassignRes);
        return reassignRes;
    }

    var first = try getLetter(map, cache, op.firstLetter.?);

    if (op.type == InstructionType.HACKY_AND) {
        try cache.*.put(letter, op.num.? & first);
        return op.num.? & first;
    }

    if (op.type == InstructionType.AND or op.type == InstructionType.OR) {
        var second = try getLetter(map, cache, op.secondLetter.?);
        if (op.type == InstructionType.AND) {
            try cache.*.put(letter, first & second);
            return first & second;
        }
        try cache.*.put(letter, first | second);
        return first | second;
    }

    if (op.type == InstructionType.LSHIFT) {
        var shortNum: u4 = @truncate(op.num.?);
        try cache.*.put(letter, first << shortNum);
        return first << shortNum;
    }
    var shortNum: u4 = @truncate(op.num.?);
    try cache.*.put(letter, first >> shortNum);
    return first >> shortNum;
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    var lines = try utils.splitLines("input.txt", allocator);
    defer lines.deinit();

    var wireMap = std.StringHashMap(Instruction).init(allocator);
    defer wireMap.deinit();

    var resultCache = std.StringHashMap(u16).init(allocator);
    defer resultCache.deinit();

    for (lines.items) |line| {
        var instructionAndOutput = std.mem.tokenizeSequence(u8, line, " -> ");

        var op = instructionAndOutput.next().?;
        var output = instructionAndOutput.next().?;

        var instructionParts = std.mem.tokenizeSequence(u8, op, " ");
        var first = instructionParts.next().?;

        if (std.mem.eql(u8, first, "NOT")) {
            var notOp = Instruction{ .type = InstructionType.NOT, .firstLetter = instructionParts.next().?, .num = undefined, .secondLetter = undefined };
            try wireMap.put(output, notOp);
            continue;
        }

        var firstNumber = std.fmt.parseInt(u16, first, 10) catch {
            // Must be a regular double operation (a AND b)

            if (instructionParts.next()) |rawOperator| {
                var operator = getOp(rawOperator);
                var second = instructionParts.next().?;

                var myOp = switch (operator) {
                    InstructionType.AND, InstructionType.OR => Instruction{ .type = operator, .firstLetter = first, .secondLetter = second, .num = undefined },
                    InstructionType.LSHIFT, InstructionType.RSHIFT => Instruction{ .type = operator, .firstLetter = first, .secondLetter = undefined, .num = try std.fmt.parseInt(u4, second, 10) },
                    else => unreachable,
                };

                try wireMap.put(output, myOp);

                continue;
            }
            // x -> y
            var reassign = Instruction{ .type = InstructionType.REASSIGN, .firstLetter = first, .secondLetter = undefined, .num = undefined };
            try wireMap.put(output, reassign);
            continue;
        };

        // Edge case. and gates can have numbers too (seems to be limited to first argument).
        if (instructionParts.next()) |_| {
            // an and operation with a 1 in front.
            var second = instructionParts.next().?;
            var hackyAnd = Instruction{ .type = InstructionType.HACKY_AND, .firstLetter = second, .secondLetter = undefined, .num = firstNumber };
            try wireMap.put(output, hackyAnd);
            continue;
        }

        var literalOp = Instruction{ .type = InstructionType.LITERAL, .num = firstNumber, .firstLetter = undefined, .secondLetter = undefined };
        try wireMap.put(output, literalOp);
    }

    var part1 = try getLetter(wireMap, &resultCache, "a");
    std.debug.print("Part 1: {}\n", .{part1});

    var resetResultCache = std.StringHashMap(u16).init(allocator);
    defer resetResultCache.deinit();
    try resetResultCache.put("b", part1);

    var part2 = try getLetter(wireMap, &resetResultCache, "a");
    std.debug.print("Part 2: {}\n", .{part2});
}
