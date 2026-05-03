import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final int id;
  final String title;
  final String? posterPath;
  final String overview;
  final double voteAverage;
  final String? releaseDate;
  final List<int> genreIds;

  const Movie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.overview,
    required this.voteAverage,
    this.releaseDate,
    required this.genreIds,
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
        releaseDate,
        genreIds,
      ];
}
