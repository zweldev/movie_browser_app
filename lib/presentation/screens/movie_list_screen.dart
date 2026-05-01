import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/theme_toggle_button.dart';
import '../cubit/movie_list_cubit.dart';
import '../widgets/movie_card.dart';
import '../widgets/error_widget.dart';
import '../widgets/horizontal_shimmer_loading.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const MovieListScreen({super.key, required this.toggleTheme});

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
          return MovieDetailScreen(
            movieId: movieId,
            toggleTheme: widget.toggleTheme,
          );
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

  Widget _buildPopularSection(BuildContext context) {
    return BlocBuilder<MovieListCubit, MovieListState>(
      builder: (context, state) {
        final movies = state.getMoviesByCategory(MovieCategory.popular);
        final screenWidth = MediaQuery.of(context).size.width;
        final spacing = screenWidth < 600 ? 12.0 : 16.0;
        final popularCardWidth = screenWidth * 0.85;
        final popularCardHeight =
            popularCardWidth * 1.5; // 2:3 poster aspect ratio

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing + 4,
                screenWidth < 600 ? 16 : 24,
                spacing + 4,
                screenWidth < 600 ? 8 : 12,
              ),
              child: Text(
                'Popular',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth < 600 ? 20 : 24,
                    ),
              ),
            ),
            if (state.isLoading && movies.isEmpty)
              HorizontalShimmerLoading(
                height: popularCardHeight,
                itemWidth: screenWidth - (spacing * 2),
                spacing: spacing,
              )
            else if (state.error != null && movies.isEmpty)
              SizedBox(
                height: popularCardHeight,
                child: Center(
                  child: AppErrorWidget(
                    message: state.error!,
                    onRetry: () => context.read<MovieListCubit>().loadMovies(
                          MovieCategory.popular,
                          refresh: true,
                        ),
                  ),
                ),
              )
            else if (movies.isEmpty)
              SizedBox(
                height: popularCardHeight,
                child: Center(
                  child: Text(
                    'No movies found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              )
            else
              SizedBox(
                height: popularCardHeight,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification &&
                        notification.metrics.extentAfter < 200) {
                      context
                          .read<MovieListCubit>()
                          .loadMoreMovies(MovieCategory.popular);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollControllers[MovieCategory.popular],
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: spacing),
                    itemCount: movies.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= movies.length) {
                        return SizedBox(
                          width: screenWidth < 600 ? 40 : 60,
                          child: Center(
                            child: SizedBox(
                              width: screenWidth < 600 ? 16 : 20,
                              height: screenWidth < 600 ? 16 : 20,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      }
                      final movie = movies[index];
                      return Container(
                        width: screenWidth - (spacing * 2),
                        margin: EdgeInsets.only(right: spacing),
                        child: MovieCard(
                          movie: movie,
                          index: index,
                          category: MovieCategory.popular,
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

  Widget _buildCategorySection(
    BuildContext context,
    String title,
    MovieCategory category,
  ) {
    return BlocBuilder<MovieListCubit, MovieListState>(
      builder: (context, state) {
        final movies = state.getMoviesByCategory(category);
        final screenWidth = MediaQuery.of(context).size.width;
        final crossAxisCount = screenWidth < 360
            ? 2
            : screenWidth < 600
                ? 2
                : screenWidth < 900
                    ? 3
                    : 4;
        final spacing = screenWidth < 600 ? 12.0 : 16.0;
        final cardWidth =
            (screenWidth - spacing * (crossAxisCount + 1)) / crossAxisCount;
        final childAspectRatio = screenWidth < 600 ? 0.65 : 0.7;
        final cardHeight = cardWidth / childAspectRatio;
        final sectionHeight = cardHeight;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing + 4,
                screenWidth < 600 ? 16 : 24,
                spacing + 4,
                screenWidth < 600 ? 8 : 12,
              ),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth < 600 ? 20 : 24,
                    ),
              ),
            ),
            if (state.isLoading && movies.isEmpty)
              HorizontalShimmerLoading(
                height: sectionHeight,
                itemWidth: cardWidth,
                spacing: spacing,
              )
            else if (state.error != null && movies.isEmpty)
              SizedBox(
                height: sectionHeight,
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
                height: sectionHeight,
                child: Center(
                  child: Text(
                    'No movies found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              )
            else
              SizedBox(
                height: sectionHeight,
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
                    padding: EdgeInsets.symmetric(horizontal: spacing),
                    itemCount: movies.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= movies.length) {
                        return SizedBox(
                          width: screenWidth < 600 ? 40 : 60,
                          child: Center(
                            child: SizedBox(
                              width: screenWidth < 600 ? 16 : 20,
                              height: screenWidth < 600 ? 16 : 20,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      }
                      final movie = movies[index];
                      return Container(
                        width: cardWidth,
                        margin: EdgeInsets.only(right: spacing),
                        child: MovieCard(
                          movie: movie,
                          index: index,
                          category: category,
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
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshAll,
            child: ListView(
              children: [
                _buildPopularSection(context),
                _buildCategorySection(
                    context, 'Top Rated', MovieCategory.topRated),
                _buildCategorySection(
                    context, 'Upcoming', MovieCategory.upcoming),
                const SizedBox(height: 60),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: ThemeToggleButton(onPressed: widget.toggleTheme),
          ),
        ],
      ),
    );
  }
}
