import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/movie_repository.dart';

class FavoritesState extends Equatable {
  final List<Movie> favorites;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<Movie>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [favorites, isLoading, error];
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final MovieRepository _repository;

  FavoritesCubit(this._repository) : super(const FavoritesState());

  Future<void> loadFavorites() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final favorites = await _repository.getFavorites();
      emit(state.copyWith(favorites: favorites, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addToFavorites(Movie movie) async {
    try {
      await _repository.addToFavorites(movie);
      emit(state.copyWith(favorites: [...state.favorites, movie]));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> removeFromFavorites(int movieId) async {
    try {
      await _repository.removeFromFavorites(movieId);
      emit(
        state.copyWith(
          favorites: state.favorites.where((m) => m.id != movieId).toList(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
