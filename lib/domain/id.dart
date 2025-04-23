// import 'package:dartz/dartz.dart';
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
//
// class UnexpectedValueError extends Error {
//   final ValueFailure valueFailure;
//
//   UnexpectedValueError(this.valueFailure);
//
//   @override
//   String toString() {
//     const explanation =
//         'Encountered a ValueFailure at an unrecoverable point. Terminating.';
//     return Error.safeToString('$explanation Failure was: $valueFailure');
//   }
// }
//
// abstract interface class Failure {}
//
// abstract interface class Failable {
//   Either<ValueFailure<dynamic>, Unit> get failureOrUnit;
// }
//
// abstract interface class ValueFailure<T> implements Failure {
//   T get failedValue;
// }
//
// extension FailableX on Failable {
//   bool isFailure() => failureOrUnit.isLeft();
//
//   bool isValid() => failureOrUnit.isRight();
// }
//
// @immutable
// abstract class ValueObject<T> implements Failable {
//   const ValueObject();
//
//   Either<ValueFailure<T>, T> get value;
//
//   /// Throws [UnexpectedValueError] containing the [ValueFailure]
//   T getOrCrash() {
//     // id = identity - same as writing (right) => right
//     return value.fold((f) => throw UnexpectedValueError(f), id);
//   }
//
//   T getOrElse(T defaultValue) {
//     return value.fold((l) => defaultValue, (r) => r);
//   }
//
//   T? getOrNull() {
//     return value.fold((l) => null, (r) => r);
//   }
//
//   T getIgnoringFailure() {
//     return value.fold((f) => f.failedValue, (v) => v);
//   }
//
//   @override
//   Either<ValueFailure<dynamic>, Unit> get failureOrUnit {
//     return value.fold(
//           (l) => left(l),
//           (r) => right(unit),
//     );
//   }
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is ValueObject<T> && other.value == value;
//   }
//
//   @override
//   int get hashCode => value.hashCode;
//
//   @override
//   String toString() => 'Value($value)';
// }
//
// class UniqueIdUUID extends ValueObject<String> {
//   @override
//   final Either<ValueFailure<String>, String> value;
//
//   factory UniqueIdUUID(String input) {
//     return UniqueIdUUID._(
//       validateUUID(input),
//     );
//   }
//
//   factory UniqueIdUUID.random() {
//     //wont regenerate with const
//     //ignore: prefer_const_constructors
//     return UniqueIdUUID(Uuid().v1());
//   }
//
//   const UniqueIdUUID._(this.value);
// }
//
// Either<ValueFailure<String>, String> validateUUID(String input) {
//   if (Uuid.isValidUUID(fromString: input)) {
//     return right(input);
//   } else {
//     return left(CommonValueFailure.invalidUUID(failedValue: input));
//   }
// }