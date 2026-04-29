import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/movie_repository.dart';

class SearchState extends Equatable {
  final List<Movie> results;
  final bool isLoading;
  final String? error;
  final String query;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
  });

  SearchState copyWith({
    List<Movie>? results,
    bool? isLoading,
    String? error,
    String? query,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [results, isLoading, error, query];
}

class SearchCubit extends Cubit<SearchState> {
  final MovieRepository _repository;

  SearchCubit(this._repository) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }

    emit(state.copyWith(isLoading: true, error: null, query: query));

    try {
      final results = await _repository.searchMovies(query);
      emit(state.copyWith(results: results, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void clearSearch() {
    emit(const SearchState());
  }
}
