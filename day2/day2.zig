const builtin = @import("builtin");
const std = @import("std");
const mem = std.mem;

// Allocate 100MiB of RAM up-front.
var allocator_mem: [100 * 1024 * 1024]u8 = undefined;
var fixed_allocator = std.heap.ThreadSafeFixedBufferAllocator.init(allocator_mem[0..]);
const allocator = &fixed_allocator.allocator;

pub fn main() !void {

    // Open stdout:
    var stdout_file = try std.io.getStdOut();
    const out = &stdout_file.outStream().stream;

    // Get input from file:
    var contents = try std.io.readFileAlloc(allocator, "basic_input.txt");

    // Process each line in the file:
    var lines = mem.split(contents, "\n");

    // Hash map of times each character was encountered:
    var occurred = std.AutoHashMap(u8, u32).init(allocator);

    try out.print("---------------------\n");
    try out.print("Part 1:\n");

    var two_occurrences_count: u32 = 0;
    var three_occurrences_count: u32 = 0;
    var checksum: u32 = 0;

    while (lines.next()) |line| {

        occurred.clear();

        // Count character occurrences:
        for (line) |c| {
            var result = try occurred.getOrPutValue(c, 0);
            result.value += 1;
        }

        var found_two_occurrence = false;
        var found_three_occurrence = false;

        // Scan hashmap for results:
        var it = occurred.iterator();
        while (it.next()) |next| {

            switch (next.value) {
                2 => { 
                    found_two_occurrence = true;
                },
                3 => {
                    found_three_occurrence = true;
                },
                else => {}
            }
        }

        if (found_two_occurrence) {
            two_occurrences_count += 1;
        }

        if (found_three_occurrence) {
            three_occurrences_count += 1;
        }
    }

    checksum = two_occurrences_count * three_occurrences_count;

    try out.print("Count of lines with at least one character appearing exactly two times: {c}\n", two_occurrences_count);
    try out.print("Count of lines with at least one character appearing exactly three times: {c}\n", three_occurrences_count);
    try out.print("Checksum: {}\n", checksum);

    // Part 2: determine which two lines differ by only one character:

    lines.index = 0;
    var lines_inner = lines;
    var result: ?[] const u8 = null;
    var diff_char_idx: usize = 0;
    
    while (lines.next()) |line| {

        lines_inner.index = 0;
        while (lines_inner.next()) |other_line| {

            if (lines.index == lines_inner.index) {
                continue;
            }

            if (line.len != other_line.len) {
                continue;
            }

            var diffs: u32 = 0;
            var i: usize = 0;

            while (i < line.len) : (i += 1) {
                if (line[i] != other_line[i]) {
                    diffs += 1;
                    diff_char_idx = i;
                }
            }

            if (diffs == 1) {
                result = line;
                break;
            }
        }

        if (result) |result_line| {
            break;
        }
    }

    if (result) |line| {
        try out.print("---------------------\n");
        try out.print("Part 2:\n");
        try out.print("Found line with just one difference: {}\n", line);
        try out.print("Chars in common: ");

        for (line) |c, i| {
            if (i != diff_char_idx) {
                try out.print("{c}", c);
            }
        }

        try out.print("\n");
    }
}
