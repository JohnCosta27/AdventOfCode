const std = @import("std");

const print = std.debug.print;

const Attributes = enum(u8) {
    x = 'x',
    m = 'm',
    a = 'a',
    s = 's',
};

const RuleType = enum { non_terminal, terminal_expression, terminal, non_terminal_instant };

const Expression = struct {
    attribute: Attributes,
    value: usize,
    less_than: bool,
};

const NonTerminal = struct {
    expression: Expression,

    next_rule: []const u8,
};

const TerminalExpression = struct {
    expression: Expression,

    accept: bool,
};

const NonTerminalInstant = struct {
    next_rule: []const u8,
};

const Terminal = struct {
    accept: bool,
};

const Rule = union(RuleType) {
    non_terminal: NonTerminal,
    terminal_expression: TerminalExpression,
    terminal: Terminal,
    non_terminal_instant: NonTerminalInstant,
};

const Workflow = struct {
    name: []const u8,
    rules: []Rule,
};

const Part = struct {
    x: usize,
    m: usize,
    a: usize,
    s: usize,
};

const State = enum { terminal, non_terminal };

const StateUnion = union(State) {
    terminal: bool,
    non_terminal: []const u8,
};

const Range = struct {
    low: usize,
    high: usize,

    pub fn is_empty(self: Range) bool {
        return self.low >= self.high;
    }

    pub fn size(self: Range) usize {
        if (self.is_empty()) {
            return 0;
        }

        return self.high - self.low + 1;
    }

    pub fn print_range(self: Range) void {
        print("{}<=x<={}\n", .{ self.low, self.high });
    }
};

const XmasRange = struct {
    x: Range,
    m: Range,
    a: Range,
    s: Range,

    pub fn product(self: XmasRange) usize {
        return self.x.size() * self.m.size() * self.a.size() * self.s.size();
    }
};

fn char_to_attribute(c: u8) Attributes {
    return switch (c) {
        'x' => Attributes.x,
        'm' => Attributes.m,
        'a' => Attributes.a,
        's' => Attributes.s,
        else => unreachable,
    };
}

fn build_rule(rule: []const u8) Rule {
    if (rule.len == 1) {
        return Rule{ .terminal = Terminal{ .accept = rule[0] == 'A' } };
    }

    const colon_index_optional: ?usize = for (rule, 0..) |c, index| {
        if (c != ':') {
            continue;
        }

        break index;
    } else null;

    if (colon_index_optional == null) {
        return Rule{ .non_terminal_instant = NonTerminalInstant{ .next_rule = rule } };
    }

    const colon_index = colon_index_optional.?;

    const expression = rule[0..colon_index];
    const destination = rule[colon_index + 1 ..];

    const attribute = expression[0];
    const condition = expression[1];
    const string_value = expression[2..];

    const value = std.fmt.parseInt(usize, string_value, 10) catch unreachable;

    if (destination.len == 1) {
        return Rule{ .terminal_expression = TerminalExpression{ .expression = Expression{ .attribute = char_to_attribute(attribute), .value = value, .less_than = condition == '<' }, .accept = destination[0] == 'A' } };
    }

    return Rule{ .non_terminal = NonTerminal{ .expression = Expression{ .attribute = char_to_attribute(attribute), .value = value, .less_than = condition == '<' }, .next_rule = destination } };
}

fn build_workflow(allocator: std.mem.Allocator, workflow: []const u8) !Workflow {
    const first_curly_index = for (workflow, 0..) |c, index| {
        if (c != '{') {
            continue;
        }

        break index;
    } else unreachable;

    const rule_name = workflow[0..first_curly_index];
    const rule_workflow = workflow[first_curly_index + 1 .. workflow.len - 1];

    const rule_number = std.mem.count(u8, rule_workflow, ",") + 1;

    var rules_tokenizer = std.mem.tokenizeSequence(u8, rule_workflow, ",");
    var rules = try allocator.alloc(Rule, rule_number);
    var index: usize = 0;

    while (rules_tokenizer.next()) |rule| {
        rules[index] = build_rule(rule);
        index += 1;
    }

    return Workflow{ .name = rule_name, .rules = rules };
}

fn build_part(part: []const u8) Part {
    const trimmed_part = part[1 .. part.len - 1];

    var comma_tokenizer = std.mem.tokenizeSequence(u8, trimmed_part, ",");

    const x_string = comma_tokenizer.next().?;
    const m_string = comma_tokenizer.next().?;
    const a_string = comma_tokenizer.next().?;
    const s_string = comma_tokenizer.next().?;

    const x = std.fmt.parseInt(usize, x_string[2..], 10) catch unreachable;
    const m = std.fmt.parseInt(usize, m_string[2..], 10) catch unreachable;
    const a = std.fmt.parseInt(usize, a_string[2..], 10) catch unreachable;
    const s = std.fmt.parseInt(usize, s_string[2..], 10) catch unreachable;

    return Part{ .x = x, .m = m, .a = a, .s = s };
}

fn is_expression_accepted(expression: Expression, part: Part) bool {
    if (expression.less_than) {
        return switch (expression.attribute) {
            Attributes.x => part.x < expression.value,
            Attributes.m => part.m < expression.value,
            Attributes.a => part.a < expression.value,
            Attributes.s => part.s < expression.value,
        };
    } else {
        return switch (expression.attribute) {
            Attributes.x => part.x > expression.value,
            Attributes.m => part.m > expression.value,
            Attributes.a => part.a > expression.value,
            Attributes.s => part.s > expression.value,
        };
    }
}

fn run_workflow(part: Part, workflow: Workflow) StateUnion {
    for (workflow.rules) |rule| {
        switch (rule) {
            RuleType.terminal => |terminal| {
                return StateUnion{ .terminal = terminal.accept };
            },
            RuleType.non_terminal_instant => |non_terminal_instant| {
                return StateUnion{ .non_terminal = non_terminal_instant.next_rule };
            },
            RuleType.terminal_expression => |_terminal_expression| {
                const terminal_expression: TerminalExpression = _terminal_expression;
                if (is_expression_accepted(terminal_expression.expression, part)) {
                    return StateUnion{ .terminal = terminal_expression.accept };
                }

                continue;
            },
            RuleType.non_terminal => |_non_terminal| {
                const non_terminal: NonTerminal = _non_terminal;
                if (is_expression_accepted(non_terminal.expression, part)) {
                    return StateUnion{ .non_terminal = non_terminal.next_rule };
                }

                continue;
            },
        }
    }

    unreachable;
}

fn tighten_range(xmas_range: XmasRange, range: Range, attribute: Attributes) XmasRange {
    var new_range = XmasRange{
        .x = xmas_range.x,
        .m = xmas_range.m,
        .a = xmas_range.a,
        .s = xmas_range.s,
    };

    switch (attribute) {
        Attributes.x => new_range.x = range,
        Attributes.m => new_range.m = range,
        Attributes.a => new_range.a = range,
        Attributes.s => new_range.s = range,
    }

    return new_range;
}

fn get_split_range(range: Range, expression: Expression) struct { Range, Range } {
    if (expression.less_than) {
        const truth_range = Range{ .low = range.low, .high = expression.value - 1 };
        const false_range = Range{ .low = expression.value, .high = range.high };

        return .{ truth_range, false_range };
    } else {
        const truth_range = Range{ .low = expression.value + 1, .high = range.high };
        const false_range = Range{ .low = range.low, .high = expression.value };

        return .{ truth_range, false_range };
    }
}

fn count_ranges(workflows: std.StringHashMap(Workflow), _range: XmasRange, workflow: Workflow) usize {
    var total: usize = 0;

    var range = XmasRange{
        .x = _range.x,
        .m = _range.m,
        .a = _range.a,
        .s = _range.s,
    };

    for (workflow.rules) |rule| {
        switch (rule) {
            RuleType.terminal => |_terminal| {
                const terminal: Terminal = _terminal;
                if (terminal.accept) {
                    total += range.product();
                }
            },
            RuleType.non_terminal_instant => |_non_terminal_instant| {
                const non_terminal_instant: NonTerminalInstant = _non_terminal_instant;
                total += count_ranges(workflows, range, workflows.get(non_terminal_instant.next_rule).?);
            },
            RuleType.terminal_expression => |_terminal_expression| {
                const terminal_expression: TerminalExpression = _terminal_expression;

                const current_range = switch (_terminal_expression.expression.attribute) {
                    Attributes.x => range.x,
                    Attributes.m => range.m,
                    Attributes.a => range.a,
                    Attributes.s => range.s,
                };

                const truth_range, const false_range = get_split_range(current_range, terminal_expression.expression);

                if (!truth_range.is_empty()) {
                    if (terminal_expression.accept) {
                        const tigher_range = tighten_range(range, truth_range, terminal_expression.expression.attribute);
                        total += tigher_range.product();
                    }
                }

                if (!false_range.is_empty()) {
                    range = tighten_range(range, false_range, terminal_expression.expression.attribute);
                }
            },
            RuleType.non_terminal => |_non_terminal| {
                const non_terminal: NonTerminal = _non_terminal;

                const current_range = switch (non_terminal.expression.attribute) {
                    Attributes.x => range.x,
                    Attributes.m => range.m,
                    Attributes.a => range.a,
                    Attributes.s => range.s,
                };

                const truth_range, const false_range = get_split_range(current_range, non_terminal.expression);

                if (!truth_range.is_empty()) {
                    const tigher_range = tighten_range(range, truth_range, non_terminal.expression.attribute);
                    total += count_ranges(workflows, tigher_range, workflows.get(non_terminal.next_rule).?);
                }

                if (!false_range.is_empty()) {
                    range = tighten_range(range, false_range, non_terminal.expression.attribute);
                }
            },
        }
    }

    return total;
}

pub fn solve(input: [][]const u8) !void {
    const allocator = std.heap.page_allocator;

    const workflow_count = for (input, 0..) |line, i| {
        if (line.len == 0) {
            break i;
        }
    } else unreachable;

    const parts_count = input.len - workflow_count - 1;

    var workflows = std.StringHashMap(Workflow).init(allocator);
    const parts = try allocator.alloc(Part, parts_count);

    for (input) |line| {
        if (line.len == 0) {
            break;
        }

        const workflow = try build_workflow(allocator, line);
        try workflows.put(workflow.name, workflow);
    }

    for (input[workflow_count + 1 ..], 0..) |line, i| {
        parts[i] = build_part(line);
    }

    const accepted_parts = try allocator.alloc(Part, parts_count);
    var accepted_parts_index: usize = 0;

    var next_workflow = workflows.get("in").?;

    for (parts) |part| {
        workflowLoop: while (true) {
            const workflow_result = run_workflow(part, next_workflow);
            switch (workflow_result) {
                State.terminal => |accept| {
                    if (accept) {
                        accepted_parts[accepted_parts_index] = part;
                        accepted_parts_index += 1;
                    }

                    break :workflowLoop;
                },
                State.non_terminal => |next_rule| {
                    next_workflow = workflows.get(next_rule).?;
                },
            }
        }

        next_workflow = workflows.get("in").?;
    }

    var part1: usize = 0;
    for (accepted_parts[0..accepted_parts_index]) |part| {
        part1 += part.x + part.m + part.a + part.s;
    }

    print("Part 1: {}\n", .{part1});

    allocator.free(accepted_parts);
    allocator.free(parts);

    const xmas_range = XmasRange{ .x = Range{ .low = 1, .high = 4000 }, .m = Range{ .low = 1, .high = 4000 }, .a = Range{ .low = 1, .high = 4000 }, .s = Range{ .low = 1, .high = 4000 } };

    const part2 = count_ranges(workflows, xmas_range, workflows.get("in").?);

    print("Part 2: {}\n", .{part2});
}
