import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:clean_tdd_app/core/util/input_converter.dart';
import 'package:clean_tdd_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_tdd_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_tdd_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    // Changed the name of the constructor parameter (cannot use 'this.')
    @required GetConcreteNumberTrivia concrete,
    @required GetRandomNumberTrivia random,
    @required this.inputConverter,
    // Asserts are how you can make sure that a passed in argument is not null.
    // We omit this elsewhere for the sake of brevity.
  })  : assert(concrete != null),
        assert(random != null),
        assert(inputConverter != null),
        getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random,
        super(NumberTriviaInitial());

  NumberTriviaState get initialState => NumberTriviaInitial();

  @override
  Stream<NumberTriviaState> mapEventToState(
    NumberTriviaEvent event,
  ) async* {
    // Immediately branching the logic with type checking, in order
    // for the event to be smart casted
    if (event is GetTriviaForConcreteNumber) {
      final inputEither =
          inputConverter.stringToUnsignedInteger(event.numberString);

      yield* inputEither.fold(
        (failure) async* {
          yield NumberTriviaError(message: INVALID_INPUT_FAILURE_MESSAGE);
        },
        // Although the "success case" doesn't interest us with the current test,
        // we still have to handle it somehow.
        (integer) async* {
          yield getConcreteNumberTrivia(Params(number: integer));
        },
      );
    }
  }
}
