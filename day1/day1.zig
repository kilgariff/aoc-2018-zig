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

    // Keep track of numbers seen before:
    var seen_before = std.AutoHashMap(i32, bool).init(allocator);
    defer seen_before.deinit();
    
    // Starting value:
    var val: i32 = 0;
    
    const dummy = try seen_before.put(val, true);

    // Keep track of the first duplicate:
    var first_dupe: i32 = -1;
    var final_val: i32 = -1;

    // Process each line in the file:
    var lines = mem.split(contents, "\n");

    while (first_dupe == -1) {

        var running_val: i32 = 0;

        lines.index = 0;
        while (lines.next()) |line| {
            
            var operations = std.mem.split(line, ", ");

            // Separate each word into +/- and an integer value.
            while (operations.next()) |op| {

                var factor: i32 = 0;

                if (op[0] == '+') {
                    factor = 1;

                } else if (op[0] == '-') {
                    factor = -1;
                }

                const amount = (try std.fmt.parseInt(i32, op[1..], 10)) * factor;

                running_val += amount;
                val += amount;

                const result = try seen_before.getOrPut(val);
                
                if ((result.found_existing == true) and (first_dupe == -1)) {
                    first_dupe = val;
                } else {
                    result.kv.value = true;
                }
            }
        }

        if (final_val == -1) {
            final_val = running_val;
        } 
    }

    try out.print("Final frequency: {}\n", final_val);
    try out.print("First duplicate frequency : {}\n", first_dupe);
}
