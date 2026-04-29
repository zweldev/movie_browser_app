import '../../core/constants/constants.dart';
import '../../core/network/api_client.dart';
import '../models/movie_model.dart';

class MovieRemoteDataSource {
  final ApiClient _apiClient;

  MovieRemoteDataSource(this._apiClient);

  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    final response = await _apiClient.get(
      ApiConstants.popularMovies,
      queryParameters: {'page': page},
    );
    final results = response.data['results'] as List;
    return results.map((json) => MovieModel.fromJson(json)).toList();
  }

  Future<List<MovieModel>> getTopRatedMovies({int page = 1}) async {
    final response = await _apiClient.get(
      ApiConstants.topRatedMovies,
      queryParameters: {'page': page},
    );
    final results = response.data['results'] as List;
    return results.map((json) => MovieModel.fromJson(json)).toList();
  }

  Future<List<MovieModel>> getUpcomingMovies({int page = 1}) async {
    final response = await _apiClient.get(
      ApiConstants.upcomingMovies,
      queryParameters: {'page': page},
    );
    final results = response.data['results'] as List;
    return results.map((json) => MovieModel.fromJson(json)).toList();
  }

  Future<MovieModel> getMovieDetails(int movieId) async {
    final response = await _apiClient.get(
      '${ApiConstants.movieDetails}/$movieId',
    );
    return MovieModel.fromJson(response.data);
  }

  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    final response = await _apiClient.get(
      ApiConstants.searchMovies,
      queryParameters: {'query': query, 'page': page},
    );
    final results = response.data['results'] as List;
    return results.map((json) => MovieModel.fromJson(json)).toList();
  }
}
