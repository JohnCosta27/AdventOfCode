const std = @import("std");
const print = std.debug.print;

fn gcd(a: usize, b: usize) usize {
    if (b == 0) {
        return a;
    }
    return gcd(b, a % b);
}

fn lcm(a: usize, b: usize) usize {
    return (a / gcd(a, b)) * b;
}

const Node = std.DoublyLinkedList(SendingPulse).Node;

const ModuleType = enum { flipflop, conjunction, broadcaster };

const FlipFlop = struct {
    is_on: bool,

    name: []const u8, // string
    outputs: []const u8,
};

const Conjunction = struct {
    memory: []SendingPulse,

    name: []const u8, // string
    outputs: []const u8,
};

const Broadcaster = struct {
    name: []const u8, // string
    outputs: []u8,
};

const Module = union(ModuleType) {
    flipflop: FlipFlop,
    conjunction: Conjunction,
    broadcaster: Broadcaster,
};

const SendingPulse = struct {
    from: u8,
    to: u8,

    pulse: bool,
};

const UNNAMED: u8 = 255;

// pulse = true = high
fn send_pulse(allocator: std.mem.Allocator, module_map: *std.AutoHashMap(u8, Module), queue: *std.DoublyLinkedList(SendingPulse), module_index: u8, pulse: SendingPulse) !void {
    var module = module_map.get(module_index).?;

    switch (module) {
        ModuleType.broadcaster => {
            for (module.broadcaster.outputs) |output| {
                const n = try allocator.create(Node);
                n.*.data = SendingPulse{ .pulse = pulse.pulse, .from = module_index, .to = output };
                queue.*.append(n);
            }
        },
        ModuleType.flipflop => {
            if (pulse.pulse) {
                // FlipFlip doesnt to anything on a high pulse
                return;
            }

            module.flipflop.is_on = !module.flipflop.is_on;
            for (module.flipflop.outputs) |output| {
                const n = try allocator.create(Node);
                n.*.data = SendingPulse{ .pulse = module.flipflop.is_on, .from = module_index, .to = output };
                queue.append(n);
            }

            try module_map.put(module_index, module);
        },
        ModuleType.conjunction => {
            const memory_index = for (module.conjunction.memory, 0..) |memory, i| {
                if (memory.from == pulse.from) {
                    break i;
                }
            } else unreachable;

            module.conjunction.memory[memory_index] = pulse;

            const all_memory_high = for (module.conjunction.memory) |memory| {
                if (!memory.pulse) {
                    break false;
                }
            } else true;

            for (module.conjunction.outputs) |output| {
                const n = try allocator.create(Node);
                n.*.data = SendingPulse{ .pulse = !all_memory_high, .from = module_index, .to = output };
                queue.append(n);
            }

            try module_map.put(module_index, module);
        },
    }
}

pub fn solve(input: [][]const u8) !void {
    const allocator = std.heap.page_allocator;

    var name_to_number = std.StringHashMap(u8).init(allocator);
    defer name_to_number.deinit();

    var module_map = std.AutoHashMap(u8, Module).init(allocator);
    defer module_map.deinit();

    var broadcaster_index: u8 = 0;

    for (input, 0..) |line, index| {
        var arrow_tokenizer = std.mem.tokenizeSequence(u8, line, " -> ");

        var module = arrow_tokenizer.next().?;

        const module_type = module[0];
        module = module[1..];

        const built_module = switch (module_type) {
            '%' => Module{ .flipflop = FlipFlop{ .is_on = false, .name = module, .outputs = undefined } },
            '&' => Module{ .conjunction = Conjunction{ .memory = &[_]SendingPulse{}, .name = module, .outputs = undefined } },
            'b' => Module{ .broadcaster = Broadcaster{ .name = module, .outputs = undefined } },
            else => unreachable,
        };

        switch (built_module) {
            ModuleType.broadcaster => {
                broadcaster_index = @truncate(index);
            },
            else => {},
        }

        try name_to_number.put(module, @truncate(index));
        try module_map.put(@truncate(index), built_module);
    }

    for (input, 0..) |line, index| {
        var arrow_tokenizer = std.mem.tokenizeSequence(u8, line, " -> ");

        _ = arrow_tokenizer.next().?;
        const output_names = arrow_tokenizer.next().?;

        var outputs: [10]u8 = undefined;
        var output_index: usize = 0;

        var output_tokenizer = std.mem.tokenizeSequence(u8, output_names, ", ");
        while (output_tokenizer.next()) |output| {
            const output_module_number = name_to_number.get(output) orelse UNNAMED;
            outputs[output_index] = output_module_number;
            output_index += 1;

            var output_module = module_map.get(output_module_number) orelse continue;
            switch (output_module) {
                ModuleType.conjunction => {
                    var new_memory = try allocator.alloc(SendingPulse, output_module.conjunction.memory.len + 1);
                    std.mem.copyForwards(SendingPulse, new_memory, output_module.conjunction.memory);

                    new_memory[new_memory.len - 1] = SendingPulse{ .to = 0, .from = @truncate(index), .pulse = false };

                    output_module.conjunction.memory = new_memory;
                    try module_map.put(output_module_number, output_module);
                },
                else => {},
            }
        }

        var copied_outputs = try allocator.alloc(u8, output_index);
        for (0..output_index) |i| {
            copied_outputs[i] = outputs[i];
        }

        var module = module_map.get(@truncate(index)).?;
        switch (module) {
            ModuleType.broadcaster => module.broadcaster.outputs = copied_outputs,
            ModuleType.flipflop => module.flipflop.outputs = copied_outputs,
            ModuleType.conjunction => module.conjunction.outputs = copied_outputs,
        }

        try module_map.put(@truncate(index), module);
    }

    var work_queue = std.DoublyLinkedList(SendingPulse){};

    var low: usize = 0;
    var high: usize = 0;

    const PART_1 = 1000;

    for (0..PART_1) |_| {
        var n = try allocator.create(Node);
        n.data = SendingPulse{ .from = 0, .to = broadcaster_index, .pulse = false };
        work_queue.append(n);

        while (work_queue.len > 0) {
            const pulse = work_queue.popFirst().?;

            if (pulse.data.pulse) {
                high += 1;
            } else {
                low += 1;
            }

            if (pulse.data.to == UNNAMED) {
                allocator.destroy(pulse);
                continue;
            }

            try send_pulse(allocator, &module_map, &work_queue, pulse.data.to, pulse.data);
            allocator.destroy(pulse);
        }
    }

    const part1 = low * high;
    var part2: usize = 0;

    var module_iter = module_map.iterator();
    while (module_iter.next()) |entry| {
        var module = entry.value_ptr.*;
        switch (module) {
            ModuleType.flipflop => {
                module.flipflop.is_on = false;
                try module_map.put(entry.key_ptr.*, module);
            },
            ModuleType.conjunction => {
                for (0..module.conjunction.memory.len) |memory_index| {
                    module.conjunction.memory[memory_index].pulse = false;
                }
                try module_map.put(entry.key_ptr.*, module);
            },
            else => {},
        }
    }

    const MR = name_to_number.get("mr").?;
    const KK = name_to_number.get("kk").?;
    const GL = name_to_number.get("gl").?;
    const BB = name_to_number.get("bb").?;

    var mr_loop: usize = 0;
    var kk_loop: usize = 0;
    var gl_loop: usize = 0;
    var bb_loop: usize = 0;

    var loop_counter: usize = 0;

    topLoop: while (true) {
        loop_counter += 1;

        var n = try allocator.create(Node);
        n.data = SendingPulse{ .from = 0, .to = broadcaster_index, .pulse = false };
        work_queue.append(n);

        while (work_queue.len > 0) {
            const pulse = work_queue.popFirst().?;

            if (mr_loop == 0 and pulse.data.from == MR and pulse.data.pulse) {
                print("Setting mr_loop: {}\n", .{loop_counter});
                mr_loop = loop_counter;
            }

            if (kk_loop == 0 and pulse.data.from == KK and pulse.data.pulse) {
                print("Setting kk_loop: {}\n", .{loop_counter});
                kk_loop = loop_counter;
            }

            if (gl_loop == 0 and pulse.data.from == GL and pulse.data.pulse) {
                print("Setting gl_loop: {}\n", .{loop_counter});
                gl_loop = loop_counter;
            }

            if (bb_loop == 0 and pulse.data.from == BB and pulse.data.pulse) {
                print("Setting bb_loop: {}\n", .{loop_counter});
                bb_loop = loop_counter;
            }

            if (mr_loop != 0 and kk_loop != 0 and gl_loop != 0 and bb_loop != 0) {
                part2 = lcm(mr_loop, lcm(kk_loop, lcm(gl_loop, bb_loop)));
                break :topLoop;
            }

            if (pulse.data.to == UNNAMED) {
                allocator.destroy(pulse);
                continue;
            }

            try send_pulse(allocator, &module_map, &work_queue, pulse.data.to, pulse.data);
            allocator.destroy(pulse);
        }
    }

    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});
}
