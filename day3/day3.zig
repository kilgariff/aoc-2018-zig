const std = @import("std");
const mem = std.mem;

const Claim = struct {
    id: usize,
    x: i32,
    y: i32,
    w: i32,
    h: i32    
};

fn abs(val :i32) i32 {
    if (val > 0) {
        return val;
    } else {
        return -val;
    }
}

// Allocate 100MiB of RAM up-front.
var allocator_mem: [100 * 1024 * 1024]u8 = undefined;
var fixed_allocator = std.heap.ThreadSafeFixedBufferAllocator.init(allocator_mem[0..]);
const allocator = &fixed_allocator.allocator;

pub fn main() !void {

    // Open stdout:
    var stdout_file = try std.io.getStdOut();
    const out = &stdout_file.outStream().stream;

    // Get input from file:
    var contents = try std.io.readFileAlloc(allocator, "input.txt");

    // Process each line in the file:
    var lines = mem.split(contents, "\n");
    var claims = std.ArrayList(Claim).init(allocator);

    while (lines.next()) |line| {

        var claim :Claim = undefined;
        var parts = mem.split(line, "@");

        // ID:
        if (parts.next()) |id| {
            claim.id = id[1];
        }

        // Coords:
        if (parts.next()) |coords| {
            var coord_parts = mem.split(coords, ": ");

            // Position:
            if (coord_parts.next()) |pos| {
                var xy = mem.split(pos, ",");

                if (xy.next()) |x| {
                    claim.x = try std.fmt.parseInt(i32, x, 10);
                }

                if (xy.next()) |y| {
                    claim.y = try std.fmt.parseInt(i32, y, 10);
                }
            }

            // Size:
            if (coord_parts.next()) |size| {
                var wh = mem.split(size, "x");

                if (wh.next()) |w| {
                    claim.w = try std.fmt.parseInt(i32, w, 10);
                }

                if (wh.next()) |h| {
                    claim.h = try std.fmt.parseInt(i32, h, 10);
                }
            }
        }

        try claims.append(claim);
    }

    // Part 1
    try out.print("---------------\n");
    try out.print("Part 1\n");

    for (claims.toSlice()) |claim_a, i| {
        for (claims.toSlice()[i + 1..]) |claim_b| {

            // try out.print("# Testing {} and {}\n", claim_a.id, claim_b.id);

            if (claim_a.x + claim_a.w > claim_b.x
            and claim_a.x < claim_b.x + claim_b.w
            and claim_a.y + claim_a.h > claim_b.y
            and claim_a.y < claim_b.y + claim_b.h)
            {
                var overlap_x :i32 = 0;
                if (claim_a.x > claim_b.x) {
                    overlap_x = std.math.min(claim_a.w, claim_b.x + claim_b.w - claim_a.x);
                } else {
                    overlap_x = std.math.min(claim_b.w, claim_a.x + claim_a.w - claim_b.x);
                }

                var overlap_y :i32 = 0;
                if (claim_a.y > claim_b.y) {
                    overlap_y = std.math.min(claim_a.h, claim_b.y + claim_b.h - claim_a.y);
                } else {
                    overlap_y = std.math.min(claim_b.h, claim_a.y + claim_a.h - claim_b.y);
                }

                try out.print("\t{} and {} overlap by {}, {}\n", claim_a.id, claim_b.id, overlap_x, overlap_y);
            }
        }
    }

    // Part 2
    try out.print("---------------\n");
    try out.print("Part 2\n");
}