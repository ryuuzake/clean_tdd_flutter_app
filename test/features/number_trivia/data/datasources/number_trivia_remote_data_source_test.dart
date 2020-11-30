import 'dart:convert';

import 'package:clean_tdd_app/core/error/exceptions.dart';
import 'package:clean_tdd_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_tdd_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_tdd_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl dataSourceImpl;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSourceImpl = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
      (_) async => http.Response(fixture('trivia.json'), 200),
    );
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
      (_) async => http.Response('Something went wrong', 404),
    );
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with number 
        being the endpoint and with application/json header''',
      () {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        dataSourceImpl.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockHttpClient.get(
          'http://numbersapi.com/$tNumber',
          headers: {
            'Content-Type': 'application/json',
          },
        ));
      },
    );

    test(
      'should return NumberTriviaModel when the response code is 200 (OK)',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        final result = await dataSourceImpl.getConcreteNumberTrivia(tNumber);
        // assert
        expect(result, tNumberTriviaModel);
      },
    );

    test(
      'should throw a ServerException when the response code is 404 (NOT FOUNT) or other',
      () async {
        // arrange
        setUpMockHttpClientFailure404();
        // act
        final call = dataSourceImpl.getConcreteNumberTrivia;
        // assert
        expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with number 
        being the endpoint and with application/json header''',
      () {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        dataSourceImpl.getRandomNumberTrivia();
        // assert
        verify(mockHttpClient.get(
          'http://numbersapi.com/random',
          headers: {
            'Content-Type': 'application/json',
          },
        ));
      },
    );

    test(
      'should return NumberTriviaModel when the response code is 200 (OK)',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        final result = await dataSourceImpl.getRandomNumberTrivia();
        // assert
        expect(result, tNumberTriviaModel);
      },
    );

    test(
      'should throw a ServerException when the response code is 404 (NOT FOUNT) or other',
      () async {
        // arrange
        setUpMockHttpClientFailure404();
        // act
        final call = dataSourceImpl.getRandomNumberTrivia;
        // assert
        expect(() => call(), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });
}
