import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  // If the subclass have some properties, they'll get passed to this constructor
  // so that Equatable can perform value comparison.
  const Failure();

  @override
  List<Object> get props => [];
}

// General failures.
class ServerFailure extends Failure {}

class CacheFailure extends Failure {}
