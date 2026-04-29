import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/movie_repository.dart';

class MovieDetailState extends Equatable {
  final Movie? movie;
  final bool isFavorite;
  final bool isLoading;
  final String? error;

  const MovieDetailState({
    this.movie,
    this.isFavorite = false,
    this.isLoading = false,
    this.error,
  });

  MovieDetailState copyWith({
    Movie? movie,
    bool? isFavorite,
    bool? isLoading,
    String? error,
  }) {
    return MovieDetailState(
      movie: movie ?? this.movie,
      isFavorite: isFavorite ?? this.isFavorite,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [movie, isFavorite, isLoading, error];
}

class MovieDetailCubit extends Cubit<MovieDetailState> {
  final MovieRepository _repository;

  MovieDetailCubit(this._repository) : super(const MovieDetailState());

  Future<void> loadMovieDetails(int movieId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final movie = await _repository.getMovieDetails(movieId);
      final isFavorite = await _repository.isFavorite(movieId);
      emit(
        state.copyWith(movie: movie, isFavorite: isFavorite, isLoading: false),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> toggleFavorite() async {
    if (state.movie == null) return;

    try {
      if (state.isFavorite) {
        await _repository.removeFromFavorites(state.movie!.id);
        emit(state.copyWith(isFavorite: false));
      } else {
        await _repository.addToFavorites(state.movie!);
        emit(state.copyWith(isFavorite: true));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
