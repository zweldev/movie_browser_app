import 'package:hive/hive.dart';
import '../../domain/entities/movie.dart';

class MovieModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? posterPath;

  @HiveField(3)
  final String? backdropPath;

  @HiveField(4)
  final String overview;

  @HiveField(5)
  final double voteAverage;

  @HiveField(6)
  final int voteCount;

  @HiveField(7)
  final String? releaseDate;

  @HiveField(8)
  final List<int> genreIds;

  @HiveField(9)
  final double popularity;

  @HiveField(10)
  final String? originalLanguage;

  MovieModel({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    this.releaseDate,
    required this.genreIds,
    required this.popularity,
    this.originalLanguage,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    List<int> genresList = [];
    if (json['genre_ids'] != null) {
      genresList = (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [];
    } else if (json['genres'] != null) {
      genresList = (json['genres'] as List<dynamic>?)
              ?.map((e) => e['id'] as int)
              .toList() ??
          [];
    }
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      releaseDate: json['release_date'] as String?,
      genreIds: genresList,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      originalLanguage: json['original_language'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'overview': overview,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'popularity': popularity,
      'original_language': originalLanguage,
    };
  }

  factory MovieModel.fromEntity(Movie movie) {
    return MovieModel(
      id: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      overview: movie.overview,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
      releaseDate: movie.releaseDate,
      genreIds: movie.genreIds,
      popularity: movie.popularity,
      originalLanguage: movie.originalLanguage,
    );
  }

  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
      voteAverage: voteAverage,
      voteCount: voteCount,
      releaseDate: releaseDate,
      genreIds: genreIds,
      popularity: popularity,
      originalLanguage: originalLanguage,
    );
  }
}

class MovieModelAdapter extends TypeAdapter<MovieModel> {
  @override
  final int typeId = 0;

  @override
  MovieModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieModel(
      id: fields[0] as int,
      title: fields[1] as String,
      posterPath: fields[2] as String?,
      backdropPath: fields[3] as String?,
      overview: fields[4] as String,
      voteAverage: fields[5] as double,
      voteCount: fields[6] as int,
      releaseDate: fields[7] as String?,
      genreIds: (fields[8] as List).cast<int>(),
      popularity: fields[9] as double,
      originalLanguage: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MovieModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.posterPath)
      ..writeByte(3)
      ..write(obj.backdropPath)
      ..writeByte(4)
      ..write(obj.overview)
      ..writeByte(5)
      ..write(obj.voteAverage)
      ..writeByte(6)
      ..write(obj.voteCount)
      ..writeByte(7)
      ..write(obj.releaseDate)
      ..writeByte(8)
      ..write(obj.genreIds)
      ..writeByte(9)
      ..write(obj.popularity)
      ..writeByte(10)
      ..write(obj.originalLanguage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
