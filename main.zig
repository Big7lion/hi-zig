const std = @import("std");

pub fn main() void {
  std.debug.print("hello, {s}!\n", .{"World"});
  var x: u16 = 0;
}

