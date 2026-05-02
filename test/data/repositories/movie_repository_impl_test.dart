import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_browser_app/data/datasources/movie_local_datasource.dart';
import 'package:movie_browser_app/data/datasources/movie_remote_datasource.dart';
import 'package:movie_browser_app/data/models/movie_model.dart';
import 'package:movie_browser_app/data/repositories/movie_repository_impl.dart';
import 'package:movie_browser_app/domain/entities/movie.dart';

class MockRemoteDataSource extends Mock implements MovieRemoteDataSource {}

class MockLocalDataSource extends Mock implements MovieLocalDataSource {}

MovieModel createMovieModel({int id = 1}) => MovieModel(
      id: id,
      title: 'Movie $id',
      overview: 'Overview $id',
      voteAverage: 7.5,
      voteCount: 100,
      genreIds: [1, 2],
      popularity: 50.0,
    );

Movie createMovieEntity({int id = 1}) => Movie(
      id: id,
      title: 'Movie $id',
      overview: 'Overview $id',
      voteAverage: 7.5,
      voteCount: 100,
      genreIds: [1, 2],
      popularity: 50.0,
    );

void main() {
  late MovieRepositoryImpl repository;
  late MockRemoteDataSource remoteDataSource;
  late MockLocalDataSource localDataSource;

  setUpAll(() {
    registerFallbackValue(MovieModel(
      id: 0,
      title: '',
      overview: '',
      voteAverage: 0,
      voteCount: 0,
      genreIds: [],
      popularity: 0,
    ));
  });

  setUp(() {
    remoteDataSource = MockRemoteDataSource();
    localDataSource = MockLocalDataSource();
    repository = MovieRepositoryImpl(remoteDataSource, localDataSource);
  });

  group('getPopularMovies', () {
    test('returns list of movies when remote data source succeeds', () async {
      final models = [createMovieModel(id: 1), createMovieModel(id: 2)];
      when(() => remoteDataSource.getPopularMovies(page: 1)).thenAnswer((_) async => models);

      final result = await repository.getPopularMovies();

      expect(result, [
        createMovieEntity(id: 1),
        createMovieEntity(id: 2),
      ]);
      verify(() => remoteDataSource.getPopularMovies(page: 1)).called(1);
    });

    test('passes page parameter to remote data source', () async {
      when(() => remoteDataSource.getPopularMovies(page: 5)).thenAnswer((_) async => []);

      await repository.getPopularMovies(page: 5);

      verify(() => remoteDataSource.getPopularMovies(page: 5)).called(1);
    });

    test('throws exception when remote data source fails', () async {
      when(() => remoteDataSource.getPopularMovies(page: 1)).thenThrow(Exception('Network error'));

      expect(
        () => repository.getPopularMovies(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getTopRatedMovies', () {
    test('returns list of movies when remote data source succeeds', () async {
      final models = [createMovieModel(id: 3), createMovieModel(id: 4)];
      when(() => remoteDataSource.getTopRatedMovies(page: 1)).thenAnswer((_) async => models);

      final result = await repository.getTopRatedMovies();

      expect(result, [
        createMovieEntity(id: 3),
        createMovieEntity(id: 4),
      ]);
      verify(() => remoteDataSource.getTopRatedMovies(page: 1)).called(1);
    });

    test('throws exception when remote data source fails', () async {
      when(() => remoteDataSource.getTopRatedMovies(page: 1)).thenThrow(Exception('Timeout'));

      expect(
        () => repository.getTopRatedMovies(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getUpcomingMovies', () {
    test('returns list of movies when remote data source succeeds', () async {
      final models = [createMovieModel(id: 5)];
      when(() => remoteDataSource.getUpcomingMovies(page: 1)).thenAnswer((_) async => models);

      final result = await repository.getUpcomingMovies();

      expect(result, [createMovieEntity(id: 5)]);
      verify(() => remoteDataSource.getUpcomingMovies(page: 1)).called(1);
    });

    test('throws exception when remote data source fails', () async {
      when(() => remoteDataSource.getUpcomingMovies(page: 1)).thenThrow(Exception('Server error'));

      expect(
        () => repository.getUpcomingMovies(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getMovieDetails', () {
    test('returns movie when remote data source succeeds', () async {
      const movieId = 42;
      final model = createMovieModel(id: movieId);
      when(() => remoteDataSource.getMovieDetails(movieId)).thenAnswer((_) async => model);

      final result = await repository.getMovieDetails(movieId);

      expect(result, createMovieEntity(id: movieId));
      verify(() => remoteDataSource.getMovieDetails(movieId)).called(1);
    });

    test('throws exception when remote data source fails', () async {
      const movieId = 99;
      when(() => remoteDataSource.getMovieDetails(movieId)).thenThrow(Exception('Not found'));

      expect(
        () => repository.getMovieDetails(movieId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('searchMovies', () {
    test('returns list of movies when remote data source succeeds', () async {
      final models = [createMovieModel(id: 1), createMovieModel(id: 2)];
      when(() => remoteDataSource.searchMovies('action', page: 1)).thenAnswer((_) async => models);

      final result = await repository.searchMovies('action');

      expect(result, [
        createMovieEntity(id: 1),
        createMovieEntity(id: 2),
      ]);
      verify(() => remoteDataSource.searchMovies('action', page: 1)).called(1);
    });

    test('passes page parameter to remote data source', () async {
      when(() => remoteDataSource.searchMovies('drama', page: 3)).thenAnswer((_) async => []);

      await repository.searchMovies('drama', page: 3);

      verify(() => remoteDataSource.searchMovies('drama', page: 3)).called(1);
    });

    test('throws exception when remote data source fails', () async {
      when(() => remoteDataSource.searchMovies('test', page: 1)).thenThrow(Exception('Search failed'));

      expect(
        () => repository.searchMovies('test'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getFavorites', () {
    test('returns list of movies when local data source succeeds', () async {
      final models = [createMovieModel(id: 1), createMovieModel(id: 2)];
      when(() => localDataSource.getFavorites()).thenAnswer((_) async => models);

      final result = await repository.getFavorites();

      expect(result, [
        createMovieEntity(id: 1),
        createMovieEntity(id: 2),
      ]);
      verify(() => localDataSource.getFavorites()).called(1);
    });

    test('returns empty list when no favorites exist', () async {
      when(() => localDataSource.getFavorites()).thenAnswer((_) async => []);

      final result = await repository.getFavorites();

      expect(result, isEmpty);
    });

    test('throws exception when local data source fails', () async {
      when(() => localDataSource.getFavorites()).thenThrow(Exception('Database error'));

      expect(
        () => repository.getFavorites(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('addToFavorites', () {
    test('calls local data source with correct model', () async {
      final movie = createMovieEntity(id: 1);
      MovieModel? capturedModel;
      when(() => localDataSource.addToFavorites(any())).thenAnswer((invocation) async {
        capturedModel = invocation.positionalArguments[0] as MovieModel;
      });

      await repository.addToFavorites(movie);

      expect(capturedModel?.id, 1);
      verify(() => localDataSource.addToFavorites(any())).called(1);
    });

    test('throws exception when local data source fails', () async {
      final movie = createMovieEntity(id: 1);
      when(() => localDataSource.addToFavorites(any())).thenThrow(Exception('Storage full'));

      expect(
        () => repository.addToFavorites(movie),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('removeFromFavorites', () {
    test('calls local data source with correct movie id', () async {
      const movieId = 42;
      when(() => localDataSource.removeFromFavorites(movieId)).thenAnswer((_) async {});

      await repository.removeFromFavorites(movieId);

      verify(() => localDataSource.removeFromFavorites(movieId)).called(1);
    });

    test('throws exception when local data source fails', () async {
      const movieId = 42;
      when(() => localDataSource.removeFromFavorites(movieId)).thenThrow(Exception('Delete failed'));

      expect(
        () => repository.removeFromFavorites(movieId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('isFavorite', () {
    test('returns true when movie is in favorites', () async {
      const movieId = 1;
      when(() => localDataSource.isFavorite(movieId)).thenAnswer((_) async => true);

      final result = await repository.isFavorite(movieId);

      expect(result, isTrue);
      verify(() => localDataSource.isFavorite(movieId)).called(1);
    });

    test('returns false when movie is not in favorites', () async {
      const movieId = 2;
      when(() => localDataSource.isFavorite(movieId)).thenAnswer((_) async => false);

      final result = await repository.isFavorite(movieId);

      expect(result, isFalse);
    });

    test('throws exception when local data source fails', () async {
      const movieId = 3;
      when(() => localDataSource.isFavorite(movieId))
      .thenThrow(Exception('Query error'));

      expect(
        () => repository.isFavorite(movieId),
        throwsA(isA<Exception>()),
      );
    });
  });
}
