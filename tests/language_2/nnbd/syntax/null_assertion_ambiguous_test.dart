// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// SharedOptions=--enable-experiment=non-nullable
import 'package:expect/expect.dart';

class C {
  C operator*(int? other) => this;
  Object? operator-() => null;
}

// Test ambiguous cases of trailing "!" syntax.  Where possible, we verify that
// both the compiler and the runtime resolve the ambiguity correctly.
main() async {
  Object? a = null;

  // `throw a!` means `throw (a!)`, not `(throw a)!`.  Since it's a compile-time
  // error for a thrown expression to be potentially nullable, this is
  // sufficient to verify that the compiler has resolved the ambiguity
  // correctly.  Unforunately there's no good way to test the runtime behavior
  // because `throw a` wouldn't complete anyway.
  Expect.throws(() {
      throw a!;
  });

  // `() => a!` means `() => (a!)`, not `(() => a)!`.  We check the compile-time
  // behavior by trying to assign to a function returning non-null.  We check
  // the runtime behavior by ensuring that a call to the closure causes an
  // exception in the correct circumstances.
  var x1 = () => a!;
  Object Function() x2 = x1;
  Expect.throws(() {
      x1();
  });

  // `x = a!` means `x = (a!)`, not `(x = a)!`.  We check the compile-time
  // behavior by trying to assign to a non-nullable variable.  We check the
  // runtime behavior by verifying that the exception is thrown before an
  // assignment occurs.
  Object x3;
  Expect.throws(() {
      x3 = a!;
  });
  Object? x4 = 0;
  Expect.throws(() {
      x4 = a!;
  });
  Expect.equals(x4, 0);

  // `true ? null : a!` means `true ? null : (a!)`, not `(true ? null : a)!`.
  // We check the compile-time behavior by checking that the inferred type of
  // the expression is nullable.  We check the runtime behavior by verifying
  // that a null value can propagate from the true branch of the conditional.
  var x5 = true ? null : a!;
  x5 = null;

  // `x * i!` means `x * (i!)`, not `(x * i)!`.  We check the compile-time
  // behavior by checking that the multiplication is accepted even though i is
  // nullable.  We check the runtime behavior by using an object whose operator*
  // ignores its argument, and verify that the appropriate exception is still
  // thrown.
  var x6 = 2;
  int? i = 2;
  x6 * i!;
  var x7 = new C();
  Expect.throws(() {
      x7 * i!;
  });

  // `-x!` means `-(x!)`, not `(-x)!`.  We check the compile-time behavior by
  // checking that the negation is accepted even though x is nullable.  We check
  // the runtime behavior by using an object whose operator- returns null.
  int? x8 = 2;
  -x8!;
  var x9 = new C();
  -x9!;

  // `await x!` means `await (x!)`, not `(await x)!`.  We check the compile-time
  // behavior by checking that the inferred type of the expression is nullable.
  // We check the runtime behavior by ensuring that the future completes to a
  // null value, and this does not produce an exception.
  var x10 = new Future<Object?>.value(null);
  var x11 = await x10!;
  x11 = null;
}
