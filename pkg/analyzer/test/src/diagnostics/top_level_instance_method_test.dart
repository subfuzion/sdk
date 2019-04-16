// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/error/codes.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dart/resolution/driver_resolution.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(TopLevelInstanceMethodTest);
  });
}

@reflectiveTest
class TopLevelInstanceMethodTest extends DriverResolutionTest {
  test_noParameter() async {
    await assertErrorCodesInCode('''
class A {
  f() => 0;
}
var x = new A().f();
''', [StrongModeCode.TOP_LEVEL_INSTANCE_METHOD]);
  }

  test_parameter() async {
    await assertNoErrorsInCode('''
class A {
  int f(v) => 0;
}
var x = new A().f(0);
''');
  }

  test_parameter_generic() async {
    await assertErrorCodesInCode('''
class A {
  int f<T>(v) => 0;
}
var x = new A().f(0);
''', [StrongModeCode.TOP_LEVEL_INSTANCE_METHOD]);
  }

  test_parameter_generic_explicit() async {
    await assertNoErrorsInCode('''
class A {
  int f<T>(v) => 0;
}
var x = new A().f<int>(0);
''');
  }

  test_static() async {
    await assertNoErrorsInCode('''
class A {
  static f() => 0;
}
var x = A.f();
''');
  }

  test_tearOff() async {
    await assertErrorCodesInCode('''
class A {
  f() => 0;
}
var x = new A().f;
''', [StrongModeCode.TOP_LEVEL_INSTANCE_METHOD]);
  }

  test_tearOff_parameter() async {
    await assertErrorCodesInCode('''
class A {
  int f(v) => 0;
}
var x = new A().f;
''', [StrongModeCode.TOP_LEVEL_INSTANCE_METHOD]);
  }

  test_tearoff_static() async {
    await assertNoErrorsInCode('''
class A {
  static f() => 0;
}
var x = A.f;
''');
  }
}
