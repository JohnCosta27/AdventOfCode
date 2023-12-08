const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

fn countCards(cards: []const u8) !*std.AutoHashMap(u8, u8) {
    var allocator = std.heap.page_allocator;
    var sameCards = std.AutoHashMap(u8, u8).init(allocator);
    // defer allocator.free(sameCards);

    for (cards) |c| {
        if (sameCards.get(c)) |num| {
            try sameCards.put(c, num + 1);
        } else {
            try sameCards.put(c, 1);
        }
    }

    return &sameCards;
}

// At least 1 joker.
fn fiveOfAKindJoker(cards: []const u8) !bool {
    var c = try countCards(cards);
    if (c.get('J')) |_| {
        return try fourOfAKind(cards) or try fullHouse(cards);
    }
    return false;
}

fn fiveOfAKind(cards: []const u8) !bool {
    var firstCard = cards[0];
    for (cards) |c| {
        if (c != firstCard) {
            return false;
        }
    }
    return true;
}

fn fourOfAKind(cards: []const u8) !bool {
    var allocator = std.heap.page_allocator;
    var sameCards = std.AutoHashMap(u8, u8).init(allocator);
    // defer allocator.free(sameCards);

    for (cards) |c| {
        if (sameCards.get(c)) |num| {
            try sameCards.put(c, num + 1);
        } else {
            try sameCards.put(c, 1);
        }
    }

    return sameCards.get(cards[0]).? == 4 or sameCards.get(cards[1]).? == 4;
}

// AAKKJ
// AAAJK
fn fourOfAKindJoker(cards: []const u8) !bool {
    var c = try countCards(cards);
    if (c.get('J')) |numOfJacks| {
        return (try threeOfAKind(cards)) or (try twoPair(cards) and numOfJacks == 2);
    }
    return false;
}

fn fullHouse(cards: []const u8) !bool {
    return try threeOfAKind(cards) and try pair(cards);
}

// AAKKJ
// AKK2J
fn fullHouseJoker(cards: []const u8) !bool {
    var c = try countCards(cards);
    if (c.get('J')) |_| {
        return try twoPair(cards);
    }
    return false;
}

fn threeOfAKind(cards: []const u8) !bool {
    var allocator = std.heap.page_allocator;
    var sameCards = std.AutoHashMap(u8, u8).init(allocator);
    // defer allocator.free(sameCards);

    for (cards) |c| {
        if (sameCards.get(c)) |num| {
            try sameCards.put(c, num + 1);
        } else {
            try sameCards.put(c, 1);
        }
    }

    var iter = sameCards.iterator();
    while (iter.next()) |entry| {
        if (entry.value_ptr.* == 3) {
            return true;
        }
    }
    return false;
}

// 1233J
fn threeOfAKindJoker(cards: []const u8) !bool {
    var c = try countCards(cards);
    if (c.get('J')) |_| {
        return try pair(cards);
    }
    return false;
}

fn twoPair(cards: []const u8) !bool {
    var allocator = std.heap.page_allocator;
    var sameCards = std.AutoHashMap(u8, u8).init(allocator);
    // defer allocator.free(sameCards);

    for (cards) |c| {
        if (sameCards.get(c)) |num| {
            try sameCards.put(c, num + 1);
        } else {
            try sameCards.put(c, 1);
        }
    }

    var iter = sameCards.iterator();
    var twoCounter: u8 = 0;

    while (iter.next()) |entry| {
        if (entry.value_ptr.* == 2) {
            twoCounter += 1;
        }
    }
    return twoCounter == 2;
}

// 1233J
fn twoPairJoker(cards: []const u8) !bool {
    _ = cards;
    return false;
}

fn pair(cards: []const u8) !bool {
    var allocator = std.heap.page_allocator;
    var sameCards = std.AutoHashMap(u8, u8).init(allocator);
    // defer allocator.free(sameCards);

    for (cards) |c| {
        if (sameCards.get(c)) |num| {
            try sameCards.put(c, num + 1);
        } else {
            try sameCards.put(c, 1);
        }
    }

    var iter = sameCards.iterator();
    var pairCounter: u8 = 0;

    while (iter.next()) |entry| {
        if (entry.value_ptr.* == 2) {
            pairCounter += 1;
        }
    }
    return pairCounter == 1;
}

fn pairJoker(cards: []const u8) !bool {
    var c = try countCards(cards);
    if (c.get('J')) |_| {
        return true;
    }
    return false;
}

const FIVE_OF_A_KIND = 6;
const FOUR_OF_A_KIND = 5;
const FULL_HOUSE = 4;
const THREE_OF_A_KIND = 3;
const TWO_PAIR = 2;
const PAIR = 1;
const HIGH_CARD = 0;

fn getHand(cards: []const u8) !u8 {
    if (cards.len != 5) {
        @panic("Cards should be 5");
    }

    if (try fiveOfAKind(cards)) {
        return FIVE_OF_A_KIND;
    }
    if (try fourOfAKind(cards)) {
        return FOUR_OF_A_KIND;
    }
    if (try fullHouse(cards)) {
        return FULL_HOUSE;
    }
    if (try threeOfAKind(cards)) {
        return THREE_OF_A_KIND;
    }
    if (try twoPair(cards)) {
        return TWO_PAIR;
    }
    if (try pair(cards)) {
        return PAIR;
    }

    return HIGH_CARD;
}

fn getHandPart2(cards: []const u8) !u8 {
    if (cards.len != 5) {
        @panic("Cards should be 5");
    }

    if (try fiveOfAKind(cards) or try fiveOfAKindJoker(cards)) {
        return FIVE_OF_A_KIND;
    }
    if (try fourOfAKind(cards) or try fourOfAKindJoker(cards)) {
        return FOUR_OF_A_KIND;
    }
    if (try fullHouse(cards) or try fullHouseJoker(cards)) {
        return FULL_HOUSE;
    }
    if (try threeOfAKind(cards) or try threeOfAKindJoker(cards)) {
        return THREE_OF_A_KIND;
    }
    if (try twoPair(cards) or try twoPairJoker(cards)) {
        return TWO_PAIR;
    }
    if (try pair(cards) or try pairJoker(cards)) {
        return PAIR;
    }

    return HIGH_CARD;
}

// true = cards1 is better. false = cards2 is better
fn tiebreak(cards1: []const u8, cards2: []const u8) bool {
    for (cards1, cards2) |c1, c2| {
        if (c1 == c2) {
            continue;
        }

        if (c1 == 'A') {
            return false;
        }
        if (c2 == 'A') {
            return true;
        }

        if (c1 == 'K') {
            return false;
        }
        if (c2 == 'K') {
            return true;
        }

        if (c1 == 'Q') {
            return false;
        }
        if (c2 == 'Q') {
            return true;
        }

        if (c1 == 'J') {
            return false;
        }
        if (c2 == 'J') {
            return true;
        }

        if (c1 == 'T') {
            return false;
        }
        if (c2 == 'T') {
            return true;
        }

        return c1 < c2;
    }
    @panic("shouldnt be here");
}

fn tiebreakPart2(cards1: []const u8, cards2: []const u8) bool {
    for (cards1, cards2) |c1, c2| {
        if (c1 == c2) {
            continue;
        }

        if (c1 == 'J') {
            return true;
        }
        if (c2 == 'J') {
            return false;
        }

        if (c1 == 'A') {
            return false;
        }
        if (c2 == 'A') {
            return true;
        }

        if (c1 == 'K') {
            return false;
        }
        if (c2 == 'K') {
            return true;
        }

        if (c1 == 'Q') {
            return false;
        }
        if (c2 == 'Q') {
            return true;
        }

        if (c1 == 'T') {
            return false;
        }
        if (c2 == 'T') {
            return true;
        }

        return c1 < c2;
    }
    @panic("shouldnt be here");
}

test "Tie break" {
    try expect(tiebreak("AAAA9", "AAAA8") == false);

    try expect(tiebreakPart2("AAJAA", "AJAAA") == false);
}

fn tieBreakFromInput(input: [][]const u8, c1: usize, c2: usize) bool {
    var line1 = input[c1];
    var line2 = input[c2];

    var tokeniser1 = std.mem.tokenizeSequence(u8, line1, " ");
    var tokeniser2 = std.mem.tokenizeSequence(u8, line2, " ");

    var card1 = tokeniser1.next().?;
    var card2 = tokeniser2.next().?;

    return tiebreak(card1, card2);
}

fn tieBreakFromInputPart2(input: [][]const u8, c1: usize, c2: usize) bool {
    var line1 = input[c1];
    var line2 = input[c2];

    var tokeniser1 = std.mem.tokenizeSequence(u8, line1, " ");
    var tokeniser2 = std.mem.tokenizeSequence(u8, line2, " ");

    var card1 = tokeniser1.next().?;
    var card2 = tokeniser2.next().?;

    return tiebreakPart2(card1, card2);
}

pub fn solve(input: [][]const u8) !void {
    var allocator = std.heap.page_allocator;

    var fiveOfAKindList = std.ArrayList(usize).init(allocator);
    var fourOfAKindList = std.ArrayList(usize).init(allocator);
    var fullHouseList = std.ArrayList(usize).init(allocator);
    var threeOfAKindList = std.ArrayList(usize).init(allocator);
    var twoPairList = std.ArrayList(usize).init(allocator);
    var pairList = std.ArrayList(usize).init(allocator);
    var highCardList = std.ArrayList(usize).init(allocator);

    var hands = [7]*std.ArrayList(usize){ &highCardList, &pairList, &twoPairList, &threeOfAKindList, &fullHouseList, &fourOfAKindList, &fiveOfAKindList };

    var fiveOfAKindListJoker = std.ArrayList(usize).init(allocator);
    var fourOfAKindListJoker = std.ArrayList(usize).init(allocator);
    var fullHouseListJoker = std.ArrayList(usize).init(allocator);
    var threeOfAKindListJoker = std.ArrayList(usize).init(allocator);
    var twoPairListJoker = std.ArrayList(usize).init(allocator);
    var pairListJoker = std.ArrayList(usize).init(allocator);
    var highCardListJoker = std.ArrayList(usize).init(allocator);

    var handsJoker = [7]*std.ArrayList(usize){ &highCardListJoker, &pairListJoker, &twoPairListJoker, &threeOfAKindListJoker, &fullHouseListJoker, &fourOfAKindListJoker, &fiveOfAKindListJoker };

    for (input, 0..) |line, i| {
        var tokeniser = std.mem.tokenizeSequence(u8, line, " ");
        var cards = tokeniser.next().?;

        var hand = try getHand(cards);
        try hands[hand].*.append(i);
    }

    for (input, 0..) |line, i| {
        var tokeniser = std.mem.tokenizeSequence(u8, line, " ");
        var cards = tokeniser.next().?;

        var hand = try getHandPart2(cards);
        try handsJoker[hand].*.append(i);
    }

    var fiveOfAKindSlice = try hands[6].toOwnedSlice();
    var fourOfAKindSlice = try hands[5].toOwnedSlice();
    var fullHouseSlice = try hands[4].toOwnedSlice();
    var threeOfAKindSlice = try hands[3].toOwnedSlice();
    var twoPairSlice = try hands[2].toOwnedSlice();
    var pairSlice = try hands[1].toOwnedSlice();
    var highCardSlice = try hands[0].toOwnedSlice();

    var fiveOfAKindSliceJoker = try handsJoker[6].toOwnedSlice();
    var fourOfAKindSliceJoker = try handsJoker[5].toOwnedSlice();
    var fullHouseSliceJoker = try handsJoker[4].toOwnedSlice();
    var threeOfAKindSliceJoker = try handsJoker[3].toOwnedSlice();
    var twoPairSliceJoker = try handsJoker[2].toOwnedSlice();
    var pairSliceJoker = try handsJoker[1].toOwnedSlice();
    var highCardSliceJoker = try handsJoker[0].toOwnedSlice();

    std.mem.sort(usize, fiveOfAKindSlice, input, comptime tieBreakFromInput);
    std.mem.sort(usize, fourOfAKindSlice, input, comptime tieBreakFromInput);
    std.mem.sort(usize, fullHouseSlice, input, comptime tieBreakFromInput);
    std.mem.sort(usize, threeOfAKindSlice, input, comptime tieBreakFromInput);
    std.mem.sort(usize, twoPairSlice, input, comptime tieBreakFromInput);
    std.mem.sort(usize, pairSlice, input, comptime tieBreakFromInput);
    std.mem.sort(usize, highCardSlice, input, comptime tieBreakFromInput);

    var slices = [7]*([]usize){ &highCardSlice, &pairSlice, &twoPairSlice, &threeOfAKindSlice, &fullHouseSlice, &fourOfAKindSlice, &fiveOfAKindSlice };

    var slicesPart2 = [7]*([]usize){ &highCardSliceJoker, &pairSliceJoker, &twoPairSliceJoker, &threeOfAKindSliceJoker, &fullHouseSliceJoker, &fourOfAKindSliceJoker, &fiveOfAKindSliceJoker };

    std.mem.sort(usize, fiveOfAKindSliceJoker, input, comptime tieBreakFromInputPart2);
    std.mem.sort(usize, fourOfAKindSliceJoker, input, comptime tieBreakFromInputPart2);
    std.mem.sort(usize, fullHouseSliceJoker, input, comptime tieBreakFromInputPart2);
    std.mem.sort(usize, threeOfAKindSliceJoker, input, comptime tieBreakFromInputPart2);
    std.mem.sort(usize, twoPairSliceJoker, input, comptime tieBreakFromInputPart2);
    std.mem.sort(usize, pairSliceJoker, input, comptime tieBreakFromInputPart2);
    std.mem.sort(usize, highCardSliceJoker, input, comptime tieBreakFromInputPart2);

    var part1: usize = 0;
    var counter: usize = 1;

    for (slices) |arr| {
        for (arr.*) |j| {
            var line = input[j];
            var tokeniser = std.mem.tokenizeSequence(u8, line, " ");
            _ = tokeniser.next().?;
            var bid = try std.fmt.parseInt(usize, tokeniser.next().?, 10);
            part1 += counter * bid;
            counter += 1;
        }
    }

    var part2: usize = 0;
    counter = 1;

    for (slicesPart2) |arr| {
        for (arr.*) |j| {
            var line = input[j];
            var tokeniser = std.mem.tokenizeSequence(u8, line, " ");
            _ = tokeniser.next().?;
            var bid = try std.fmt.parseInt(usize, tokeniser.next().?, 10);
            part2 += counter * bid;
            counter += 1;
        }
    }

    print("Five of a kinds: {any}\n", .{fiveOfAKindSliceJoker});
    // print("Four of a kinds: {any}\n", .{fourOfAKindSlice});
    // print("Two pairs: {any}\n", .{twoPairSlice});
    // print("full houses: {any}\n", .{fullHouseSlice});

    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});
}

// if only J and other types, then five of a kind.

// JJJJJ -> Five of a kind
// JJJJA -> Five of a kind
//   - If 4 jacks, then instant five of a kind.
// JJJAA -> If full house and 3 jacks then five of a kind.
// JJJAK -> Four of a kind.
// JJAAA -> five of a kind
