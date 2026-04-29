import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/debouncer.dart';
import '../cubit/movie_list_cubit.dart';
import '../cubit/search_cubit.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_widget.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(
    delay: const Duration(milliseconds: AppConstants.debounceDuration),
  );
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<MovieListCubit>().loadMovies(MovieCategory.popular);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final category = _getCategory(_tabController.index);
    context.read<MovieListCubit>().loadMovies(category);
  }

  MovieCategory _getCategory(int index) {
    switch (index) {
      case 0:
        return MovieCategory.popular;
      case 1:
        return MovieCategory.topRated;
      case 2:
        return MovieCategory.upcoming;
      default:
        return MovieCategory.popular;
    }
  }

  String _getCategoryName(int index) {
    switch (index) {
      case 0:
        return 'Popular';
      case 1:
        return 'Top Rated';
      case 2:
        return 'Upcoming';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search movies...',
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<SearchCubit>().clearSearch();
                            setState(() {
                              _isSearching = false;
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  _debouncer.run(() {
                    if (value.isNotEmpty) {
                      context.read<SearchCubit>().search(value);
                    }
                  });
                },
              )
            : const Text('Movies'),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
        ],
        bottom: _isSearching
            ? null
            : TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: _getCategoryName(0)),
                  Tab(text: _getCategoryName(1)),
                  Tab(text: _getCategoryName(2)),
                ],
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.6),
              ),
      ),
      body: _isSearching ? _buildSearchResults() : _buildMovieList(),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const ShimmerLoading();
        }
        if (state.error != null) {
          return AppErrorWidget(
            message: state.error!,
            onRetry: () => context.read<SearchCubit>().search(state.query),
          );
        }
        if (state.results.isEmpty && state.query.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found for "${state.query}"',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: state.results.length,
          itemBuilder: (context, index) {
            final movie = state.results[index];
            return MovieCard(
              movie: movie,
              index: index,
              onTap: () => _navigateToDetail(movie.id),
            );
          },
        );
      },
    );
  }

  Widget _buildMovieList() {
    return BlocBuilder<MovieListCubit, MovieListState>(
      builder: (context, state) {
        if (state.isLoading &&
            state
                .getMoviesByCategory(_getCategory(_tabController.index))
                .isEmpty) {
          return const ShimmerLoading();
        }
        if (state.error != null &&
            state
                .getMoviesByCategory(_getCategory(_tabController.index))
                .isEmpty) {
          return AppErrorWidget(
            message: state.error!,
            onRetry: () => context.read<MovieListCubit>().loadMovies(
              _getCategory(_tabController.index),
              refresh: true,
            ),
          );
        }
        final movies = state.getMoviesByCategory(
          _getCategory(_tabController.index),
        );
        if (movies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.movie_outlined,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No movies found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification &&
                notification.metrics.extentAfter < 200) {
              context.read<MovieListCubit>().loadMoreMovies(
                _getCategory(_tabController.index),
              );
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<MovieListCubit>().loadMovies(
                _getCategory(_tabController.index),
                refresh: true,
              );
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: movies.length + (state.isLoadingMore ? 2 : 0),
              itemBuilder: (context, index) {
                if (index >= movies.length) {
                  return const Card(
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final movie = movies[index];
                return MovieCard(
                  movie: movie,
                  index: index,
                  onTap: () => _navigateToDetail(movie.id),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _navigateToDetail(int movieId) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return MovieDetailScreen(movieId: movieId);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
