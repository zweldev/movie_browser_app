import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/movie_repository.dart';

enum MovieCategory { popular, topRated, upcoming }

abstract class MovieListEvent extends Equatable {
  const MovieListEvent();
  @override
  List<Object?> get props => [];
}

class LoadMovies extends MovieListEvent {
  final MovieCategory category;
  final bool refresh;

  const LoadMovies({required this.category, this.refresh = false});

  @override
  List<Object?> get props => [category, refresh];
}

class LoadMoreMovies extends MovieListEvent {
  final MovieCategory category;

  const LoadMoreMovies({required this.category});

  @override
  List<Object?> get props => [category];
}

class MovieListState extends Equatable {
  final List<Movie> popularMovies;
  final List<Movie> topRatedMovies;
  final List<Movie> upcomingMovies;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasReachedMax;

  const MovieListState({
    this.popularMovies = const [],
    this.topRatedMovies = const [],
    this.upcomingMovies = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  MovieListState copyWith({
    List<Movie>? popularMovies,
    List<Movie>? topRatedMovies,
    List<Movie>? upcomingMovies,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return MovieListState(
      popularMovies: popularMovies ?? this.popularMovies,
      topRatedMovies: topRatedMovies ?? this.topRatedMovies,
      upcomingMovies: upcomingMovies ?? this.upcomingMovies,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  List<Movie> getMoviesByCategory(MovieCategory category) {
    switch (category) {
      case MovieCategory.popular:
        return popularMovies;
      case MovieCategory.topRated:
        return topRatedMovies;
      case MovieCategory.upcoming:
        return upcomingMovies;
    }
  }

  @override
  List<Object?> get props => [
    popularMovies,
    topRatedMovies,
    upcomingMovies,
    isLoading,
    isLoadingMore,
    error,
    currentPage,
    hasReachedMax,
  ];
}

class MovieListCubit extends Cubit<MovieListState> {
  final MovieRepository _repository;

  MovieListCubit(this._repository) : super(const MovieListState());

  Future<void> loadMovies(
    MovieCategory category, {
    bool refresh = false,
  }) async {
    final currentPage = refresh ? 1 : state.currentPage;

    emit(state.copyWith(isLoading: true, error: null));

    try {
      List<Movie> movies;
      switch (category) {
        case MovieCategory.popular:
          movies = await _repository.getPopularMovies(page: currentPage);
          emit(
            state.copyWith(
              popularMovies: refresh
                  ? movies
                  : [...state.popularMovies, ...movies],
              isLoading: false,
              currentPage: currentPage + 1,
              hasReachedMax: movies.isEmpty,
            ),
          );
          break;
        case MovieCategory.topRated:
          movies = await _repository.getTopRatedMovies(page: currentPage);
          emit(
            state.copyWith(
              topRatedMovies: refresh
                  ? movies
                  : [...state.topRatedMovies, ...movies],
              isLoading: false,
              currentPage: currentPage + 1,
              hasReachedMax: movies.isEmpty,
            ),
          );
          break;
        case MovieCategory.upcoming:
          movies = await _repository.getUpcomingMovies(page: currentPage);
          emit(
            state.copyWith(
              upcomingMovies: refresh
                  ? movies
                  : [...state.upcomingMovies, ...movies],
              isLoading: false,
              currentPage: currentPage + 1,
              hasReachedMax: movies.isEmpty,
            ),
          );
          break;
      }
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
          emit(
            state.copyWith(
              popularMovies: [...state.popularMovies, ...movies],
              isLoadingMore: false,
              currentPage: state.currentPage + 1,
              hasReachedMax: movies.isEmpty,
            ),
          );
          break;
        case MovieCategory.topRated:
          movies = await _repository.getTopRatedMovies(page: state.currentPage);
          emit(
            state.copyWith(
              topRatedMovies: [...state.topRatedMovies, ...movies],
              isLoadingMore: false,
              currentPage: state.currentPage + 1,
              hasReachedMax: movies.isEmpty,
            ),
          );
          break;
        case MovieCategory.upcoming:
          movies = await _repository.getUpcomingMovies(page: state.currentPage);
          emit(
            state.copyWith(
              upcomingMovies: [...state.upcomingMovies, ...movies],
              isLoadingMore: false,
              currentPage: state.currentPage + 1,
              hasReachedMax: movies.isEmpty,
            ),
          );
          break;
      }
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }
}
