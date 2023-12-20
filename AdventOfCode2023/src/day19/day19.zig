const std = @import("std");
const print = std.debug.print;

// rfg{s<537:gd,x>2440:R,A}

const Condition = struct {
    category: u8, //xmas
    value: usize,
    operation: u8, // <, >
    trueCondition: []const u8,
};

const Rule = struct { conditions: std.ArrayList(*Condition), endAccept: bool, endReject: bool, endRule: []const u8 };

const Part = struct {
    x: usize,
    m: usize,
    a: usize,
    s: usize,
};

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;
    var foundEmptyLine = false;

    var ruleMap = std.StringHashMap(*Rule).init(allocator);
    var parts = std.ArrayList(*Part).init(allocator);

    for (input) |line| {
        if (line[0] == '{') {
            foundEmptyLine = true;
        }

        if (!foundEmptyLine) {
            // parse rule
            var l = line[0 .. line.len - 1];
            var index: usize = 0;
            for (l) |c| {
                if (c == '{') {
                    break;
                }
                index += 1;
            }

            var ruleName = l[0..index];
            l = l[index + 1 ..];

            var ruleList = std.ArrayList(*Condition).init(allocator);

            var commasTokens = std.mem.tokenizeSequence(u8, l, ",");
            var currentRule: []const u8 = "hello";

            while (commasTokens.next()) |rule| {
                currentRule = rule;
                if (commasTokens.peek()) |_| {
                    var dotsTokens = std.mem.tokenizeSequence(u8, rule, ":");
                    var condition = dotsTokens.next().?;
                    var name = dotsTokens.next().?;

                    var category = condition[0];
                    var operation = condition[1];

                    var c = try allocator.create(Condition);

                    c.*.category = category;
                    c.*.value = try std.fmt.parseInt(usize, condition[2..], 10);
                    c.*.operation = operation;
                    c.*.trueCondition = name;

                    try ruleList.append(c);
                }
            }

            var rule = try allocator.create(Rule);
            rule.*.endAccept = false;
            rule.*.endReject = false;

            if (currentRule[0] == 'A') {
                rule.*.endAccept = true;
            } else if (currentRule[0] == 'R') {
                rule.*.endReject = true;
            }

            rule.*.conditions = ruleList;
            rule.*.endRule = currentRule;

            try ruleMap.put(ruleName, rule);
            continue;
        }

        var l = line[1 .. line.len - 1];
        var commas = std.mem.tokenizeSequence(u8, l, ",");

        var x = commas.next().?;
        var m = commas.next().?;
        var a = commas.next().?;
        var s = commas.next().?;

        var part = try allocator.create(Part);
        part.*.x = try std.fmt.parseInt(usize, x[2..], 10);
        part.*.m = try std.fmt.parseInt(usize, m[2..], 10);
        part.*.a = try std.fmt.parseInt(usize, a[2..], 10);
        part.*.s = try std.fmt.parseInt(usize, s[2..], 10);

        try parts.append(part);
    }

    var acceptedParts = std.ArrayList(Part).init(allocator);

    var accepted: usize = 0;
    var rejected: usize = 0;

    itemChecking: for (parts.items) |part| {
        var p: Part = part.*;
        var currentRule: Rule = ruleMap.get("in").?.*;

        checking: while (true) {
            for (currentRule.conditions.items) |condition| {
                var c = condition.*;
                // print("End Rule {s}\n", .{currentRule.endRule});

                switch (c.category) {
                    'x' => {
                        if (c.operation == '<' and p.x < c.value or c.operation == '>' and p.x > c.value) {
                            // print("X accept\n", .{});
                            if (condition.trueCondition[0] == 'A') {
                                accepted += 1;
                                try acceptedParts.append(p);
                                continue :itemChecking;
                            } else if (condition.trueCondition[0] == 'R') {
                                rejected += 1;
                                continue :itemChecking;
                            }
                            currentRule = ruleMap.get(condition.trueCondition).?.*;
                            continue :checking;
                        }
                    },
                    'm' => {
                        if (c.operation == '<' and p.m < c.value or c.operation == '>' and p.m > c.value) {
                            // print("M accept\n", .{});
                            if (condition.trueCondition[0] == 'A') {
                                accepted += 1;
                                try acceptedParts.append(p);
                                continue :itemChecking;
                            } else if (condition.trueCondition[0] == 'R') {
                                rejected += 1;
                                continue :itemChecking;
                            }
                            currentRule = ruleMap.get(condition.trueCondition).?.*;
                            continue :checking;
                        }
                    },
                    'a' => {
                        if (c.operation == '<' and p.a < c.value or c.operation == '>' and p.a > c.value) {
                            // print("A accept\n", .{});
                            if (condition.trueCondition[0] == 'A') {
                                accepted += 1;
                                try acceptedParts.append(p);
                                continue :itemChecking;
                            } else if (condition.trueCondition[0] == 'R') {
                                rejected += 1;
                                continue :itemChecking;
                            }
                            currentRule = ruleMap.get(condition.trueCondition).?.*;
                            continue :checking;
                        }
                    },
                    's' => {
                        if (c.operation == '<' and p.s < c.value or c.operation == '>' and p.s > c.value) {
                            // print("S Accept\n", .{});
                            if (condition.trueCondition[0] == 'A') {
                                accepted += 1;
                                try acceptedParts.append(p);
                                continue :itemChecking;
                            } else if (condition.trueCondition[0] == 'R') {
                                rejected += 1;
                                continue :itemChecking;
                            }
                            // print("S true condition: {s}\n", .{condition.trueCondition});
                            currentRule = ruleMap.get(condition.trueCondition).?.*;
                            continue :checking;
                        }
                    },
                    else => unreachable,
                }

                // print("Reached end of rules\n", .{});
                // print("-----\n", .{});
                // Reached end of rule. But nothing was satisfied.
            }

            if (currentRule.endAccept) {
                accepted += 1;
                try acceptedParts.append(p);
                continue :itemChecking;
            } else if (currentRule.endReject) {
                rejected += 1;
                continue :itemChecking;
            }

            currentRule = ruleMap.get(currentRule.endRule).?.*;
        }
    }

    var part1: usize = 0;

    for (acceptedParts.items) |part| {
        var p: Part = part;
        part1 += p.x + p.m + p.a + p.s;
    }

    print("Part 1: {}\n", .{part1});
}
