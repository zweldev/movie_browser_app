import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_datasource.dart';
import '../datasources/movie_local_datasource.dart';
import '../models/movie_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource _remoteDataSource;
  final MovieLocalDataSource _localDataSource;

  MovieRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final models = await _remoteDataSource.getPopularMovies(page: page);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    final models = await _remoteDataSource.getTopRatedMovies(page: page);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    final models = await _remoteDataSource.getUpcomingMovies(page: page);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Movie> getMovieDetails(int movieId) async {
    final model = await _remoteDataSource.getMovieDetails(movieId);
    return model.toEntity();
  }

  @override
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final models = await _remoteDataSource.searchMovies(query, page: page);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Movie>> getFavorites() async {
    final models = await _localDataSource.getFavorites();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addToFavorites(Movie movie) async {
    await _localDataSource.addToFavorites(MovieModel.fromEntity(movie));
  }

  @override
  Future<void> removeFromFavorites(int movieId) async {
    await _localDataSource.removeFromFavorites(movieId);
  }

  @override
  Future<bool> isFavorite(int movieId) async {
    return _localDataSource.isFavorite(movieId);
  }
}
