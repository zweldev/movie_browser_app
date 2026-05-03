import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final int id;
  final String title;
  final String? posterPath;
  final String overview;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<int> genreIds;
  final double popularity;
  final String? originalLanguage;

  const Movie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    this.releaseDate,
    required this.genreIds,
    required this.popularity,
    this.originalLanguage,
  });

  String get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return '';
    return releaseDate!.split('-').first;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        posterPath,
        overview,
        voteAverage,
        voteCount,
        releaseDate,
        genreIds,
        popularity,
        originalLanguage,
      ];
}
