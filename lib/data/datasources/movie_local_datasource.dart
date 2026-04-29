import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants/constants.dart';
import '../models/movie_model.dart';

class MovieLocalDataSource {
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(AppConstants.hiveBoxName);
  }

  Future<List<MovieModel>> getFavorites() async {
    final favorites = _box.values.toList();
    return favorites
        .map((jsonString) => MovieModel.fromJson(json.decode(jsonString)))
        .toList();
  }

  Future<void> addToFavorites(MovieModel movie) async {
    await _box.put(movie.id.toString(), json.encode(movie.toJson()));
  }

  Future<void> removeFromFavorites(int movieId) async {
    await _box.delete(movieId.toString());
  }

  Future<bool> isFavorite(int movieId) async {
    return _box.containsKey(movieId.toString());
  }
}
