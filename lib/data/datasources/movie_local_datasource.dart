import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants/constants.dart';
import '../../core/network/network_exceptions.dart';
import '../models/movie_model.dart';

class MovieLocalDataSource {
  late Box<String> _box;

  Future<void> init() async {
    try {
      _box = await Hive.openBox<String>(AppConstants.hiveBoxName);
    } catch (e) {
      throw CacheException("Failed to initialize local storage");
    }
  }

  Future<List<MovieModel>> getFavorites() async {
    try {
      final favorites = _box.values.toList();
      return favorites.map((jsonString) {
        try {
          return MovieModel.fromJson(json.decode(jsonString));
        } catch (e) {
          throw CacheCorruptionException();
        }
      }).toList();
    } catch (e) {
      if (e is CacheCorruptionException) rethrow;
      throw CacheReadException();
    }
  }

  Future<void> addToFavorites(MovieModel movie) async {
    try {
      await _box.put(movie.id.toString(), json.encode(movie.toJson()));
    } catch (e) {
      throw CacheWriteException();
    }
  }

  Future<void> removeFromFavorites(int movieId) async {
    try {
      await _box.delete(movieId.toString());
    } catch (e) {
      throw CacheWriteException();
    }
  }

  Future<bool> isFavorite(int movieId) async {
    try {
      return _box.containsKey(movieId.toString());
    } catch (e) {
      throw CacheReadException();
    }
  }
}
