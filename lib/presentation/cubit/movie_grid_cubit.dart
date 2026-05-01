import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/movie_repository.dart';
import '../../../presentation/cubit/movie_list_cubit.dart';

class MovieGridState extends Equatable {
  final List<Movie> movies;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasReachedMax;

  const MovieGridState({
    this.movies = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  MovieGridState copyWith({
    List<Movie>? movies,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return MovieGridState(
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        movies,
        isLoading,
        isLoadingMore,
        error,
        currentPage,
        hasReachedMax,
      ];
}

class MovieGridCubit extends Cubit<MovieGridState> {
  final MovieRepository _repository;

  MovieGridCubit(this._repository) : super(const MovieGridState());

  Future<void> loadMovies(MovieCategory category,
      {bool refresh = false}) async {
    final currentPage = refresh ? 1 : state.currentPage;

    emit(state.copyWith(isLoading: true, error: null));

    try {
      List<Movie> movies;
      switch (category) {
        case MovieCategory.popular:
          movies = await _repository.getPopularMovies(page: currentPage);
          break;
        case MovieCategory.topRated:
          movies = await _repository.getTopRatedMovies(page: currentPage);
          break;
        case MovieCategory.upcoming:
          movies = await _repository.getUpcomingMovies(page: currentPage);
          break;
      }

      emit(state.copyWith(
        movies: refresh ? movies : [...state.movies, ...movies],
        isLoading: false,
        currentPage: currentPage + 1,
        hasReachedMax: movies.isEmpty,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadMoreMovies(MovieCategory category) async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      List<Movie> movies;
      switch (category) {
        case MovieCategory.popular:
          movies = await _repository.getPopularMovies(page: state.currentPage);
          break;
        case MovieCategory.topRated:
          movies = await _repository.getTopRatedMovies(page: state.currentPage);
          break;
        case MovieCategory.upcoming:
          movies = await _repository.getUpcomingMovies(page: state.currentPage);
          break;
      }

      emit(state.copyWith(
        movies: [...state.movies, ...movies],
        isLoadingMore: false,
        currentPage: state.currentPage + 1,
        hasReachedMax: movies.isEmpty,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }
}
