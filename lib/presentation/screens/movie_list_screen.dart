import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/movie_list_cubit.dart';
import '../widgets/movie_card.dart';
import '../widgets/error_widget.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final Map<MovieCategory, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    for (final category in MovieCategory.values) {
      _scrollControllers[category] = ScrollController();
    }
    context.read<MovieListCubit>().loadMovies(MovieCategory.popular);
    context.read<MovieListCubit>().loadMovies(MovieCategory.topRated);
    context.read<MovieListCubit>().loadMovies(MovieCategory.upcoming);
  }

  @override
  void dispose() {
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _refreshAll() async {
    final cubit = context.read<MovieListCubit>();
    await Future.wait([
      cubit.loadMovies(MovieCategory.popular, refresh: true),
      cubit.loadMovies(MovieCategory.topRated, refresh: true),
      cubit.loadMovies(MovieCategory.upcoming, refresh: true),
    ]);
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
              position: Tween<Offset>(
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

  Widget _buildMovieSection(
    BuildContext context,
    String title,
    MovieCategory category,
  ) {
    return BlocBuilder<MovieListCubit, MovieListState>(
      builder: (context, state) {
        final movies = state.getMoviesByCategory(category);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            if (state.isLoading && movies.isEmpty)
              const SizedBox(
                height: 230,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (state.error != null && movies.isEmpty)
              SizedBox(
                height: 230,
                child: Center(
                  child: AppErrorWidget(
                    message: state.error!,
                    onRetry: () => context.read<MovieListCubit>().loadMovies(
                          category,
                          refresh: true,
                        ),
                  ),
                ),
              )
            else if (movies.isEmpty)
              SizedBox(
                height: 230,
                child: Center(
                  child: Text(
                    'No movies found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              )
            else
              SizedBox(
                height: 230,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification &&
                        notification.metrics.extentAfter < 200) {
                      context.read<MovieListCubit>().loadMoreMovies(category);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollControllers[category],
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: movies.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= movies.length) {
                        return const SizedBox(
                          width: 60,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final movie = movies[index];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        child: MovieCard(
                          movie: movie,
                          index: index,
                          onTap: () => _navigateToDetail(movie.id),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          children: [
            _buildMovieSection(context, 'Popular', MovieCategory.popular),
            _buildMovieSection(context, 'Top Rated', MovieCategory.topRated),
            _buildMovieSection(context, 'Upcoming', MovieCategory.upcoming),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
