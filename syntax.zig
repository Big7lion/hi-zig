const std = @import("std");

// ----------------
// -  Assignment  -
// ----------------
// syntax: (const|var) identifier[: type] = value

// const for immutable
// var for mutable
const constant: i32 = 5;
var variable: u32 = 5;

// @as for explicit type coercion
const inferred_constant = @as(i32, 5);
var inferred_variable = @as(u32, 5000);

// undefined as any
const a: i32 = undefined;
var b: u32 = undefined;


// -----------------------------------------------------------------------
// -                               Arrays                                -
// -----------------------------------------------------------------------
// syntax: [N]T, N is number of elements
//               N could be _, which means will inferred automatically
// note: 1. use {} to declare array items
//       2. use method "len" to get the size

const c = [5]u8{'h', 'e', 'l', 'l', 'o'};
const d = [_]u8{'w', 'o', 'r', 'l', 'd'};

const length = d.len;

// -----------------------------------------------------------------------
// -                            if condition                             -
// -----------------------------------------------------------------------
// syntax: if (condition) {
//            [Statement]
//         } else {
//            [Statement]
//         }
// note: 1. condition must be bool; 
//       2. use "==" to assert equal;
//       3. {} is optional in one line code;

var x: u16 = 0;
x += if (true) 1 else 2;

// -----------------------------------------------------------------------
// -                             while loop                              -
// -----------------------------------------------------------------------
// syntax: while (condition) [: (expressions1)] {
//            [expressions2]
//         }
// flow control keywords: 1. continue; 2. break;
// note: 1. expressions1 is a continue expression

var sum: u8 = 0;
var i: u8 = 0;
while (i <= 3) : (i += 1) {
  if (i == 2) continue;
  sum += i;
}

// -----------------------------------------------------------------------
// -                              for loop                               -
// -----------------------------------------------------------------------
// syntax: for(array) |item, index| {
//            [expressions]
//         }
// note: 1. _ means the variable could be ignored
//       2. zig cannot have unused values

const forArr = [_]u8{ 'a', 'b', 'c' };

for (forArr) |character, index| {
  _ = character;
  _ = index;
}

// -----------------------------------------------------------------------
// -                              Functions                              -
// -----------------------------------------------------------------------
// syntax: fn [name!](...[argument: argumentType]) [returnDataType] {
//            [expressions]
//            return [value];
//         }

fn addFive(x: u32) u32 {
    return x + 5;
}

// -----------------------------------------------------------------------
// -                                Defer                                -
// -----------------------------------------------------------------------
// syntax: defer [Statement];
// note: 1. defer will register a callback, and the callback will trigger when
//          leave the current block;
//       2. the later the Statement defer, the early will the Statement trigger;

var deferX: f32 = 5;
{
  defer deferX += 2;
  defer deferX /= 2;
}
std.debug.print(x == 4.5); // true


// -----------------------------------------------------------------------
// -                      Errors and error handles                       -
// -----------------------------------------------------------------------
// syntax: const [error!] = error{
//           [errorCategory1],
//           [errorCategory2]
//         }
// note: 1. it really like enum
//       2. errors can union with normal type with !;
//       3. use "catch" to handle errors

// catch can provide fallback value
const AllocationError = error{OutOfMemory};
const maybe_error: AllocationError!u16 = 10;
const no_error = maybe_error catch 0;

// catch can provide fallback function
fn failingFunction() error{Oops}!void {
    return error.Oops;
}

failingFunction() catch |err| {
  std.debug.print(err == error.Oops)
  return;
}

// "try x" is a shortcut for "x catch |err| return err"
// commonly use for some functions that not handle errors
// which means, error will be handled in annother context
// tips: "try" and "catch" is not related in zig
//       (unlike other languages, for example: javascript)
fn failFn() error{Oops}!i32 {
    try failingFunction();
    return 12;
}
var v = failFn() catch |err| {
    try expect(err == error.Oops);
    return;
};

// "errdefer" is a error "defer", only execute when the function
// returned with error

var problems: u32 = 98;
fn failFnCounter() error{Oops}!void {
  errdefer problems += 1;
  try failingFunction();
}

failingFunction() catch |err| {
  try expect(err == error.Oops);
  try expect(problems == 99);
  return;
}

// error union can auto infered wihout explicit error set
fn createFile() !void {
  return error.AccessDenied;
}

const x: error{AccessDenied}!void = createFile();

// error set could be merged
const A = error{ NotFinished, CannotAccess };
const B = error{ OutOfMemory, PathNotFound };
const C = A | B;
