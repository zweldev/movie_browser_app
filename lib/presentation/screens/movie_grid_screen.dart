import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/constants.dart';
import '../../domain/entities/movie.dart';
import '../../presentation/cubit/movie_list_cubit.dart';
import '../../presentation/screens/movie_detail_screen.dart';
import '../../presentation/widgets/error_widget.dart';
import '../../presentation/widgets/loading_animation.dart';
import '../cubit/movie_grid_cubit.dart';

class MovieGridScreen extends StatefulWidget {
  final MovieCategory category;
  final VoidCallback toggleTheme;

  const MovieGridScreen({
    super.key,
    required this.category,
    required this.toggleTheme,
  });

  @override
  State<MovieGridScreen> createState() => _MovieGridScreenState();
}

class _MovieGridScreenState extends State<MovieGridScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<MovieGridCubit>().loadMovies(widget.category);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      context.read<MovieGridCubit>().loadMoreMovies(widget.category);
    }
  }

  String get _title {
    switch (widget.category) {
      case MovieCategory.popular:
        return 'Popular Movies';
      case MovieCategory.topRated:
        return 'Top Rated Movies';
      case MovieCategory.upcoming:
        return 'Upcoming Movies';
    }
  }

  void _navigateToDetail(int movieId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MovieDetailScreen(
          movieId: movieId,
          toggleTheme: widget.toggleTheme,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: BlocBuilder<MovieGridCubit, MovieGridState>(
        builder: (context, state) {
          final movies = state.movies;

          if (state.isLoading && movies.isEmpty) {
            return _buildShimmerGrid();
          }

          if (state.error != null && movies.isEmpty) {
            return Center(
              child: AppErrorWidget(
                message: state.error!,
                onRetry: () =>
                    context.read<MovieGridCubit>().loadMovies(widget.category),
              ),
            );
          }

          final screenWidth = MediaQuery.of(context).size.width;
          final crossAxisCount = screenWidth < 360
              ? 2
              : screenWidth < 600
                  ? 2
                  : screenWidth < 900
                      ? 3
                      : 4;
          final spacing = screenWidth < 600 ? 12.0 : 16.0;

          return GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: spacing),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: screenWidth < 600 ? 0.65 : 0.7,
            ),
            itemCount: movies.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= movies.length) {
                return Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final movie = movies[index];
              return _GridMovieCard(
                movie: movie,
                index: index,
                onTap: () => _navigateToDetail(movie.id),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerGrid() {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 360
        ? 2
        : screenWidth < 600
            ? 2
            : screenWidth < 900
                ? 3
                : 4;
    final spacing = screenWidth < 600 ? 12.0 : 16.0;

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: screenWidth < 600 ? 0.65 : 0.7,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: colorScheme.surfaceContainerHighest,
          highlightColor: colorScheme.surface,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }
}

class _GridMovieCard extends StatelessWidget {
  final Movie movie;
  final int index;
  final VoidCallback onTap;

  const _GridMovieCard({
    required this.movie,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: colorScheme.surface,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'movie_poster_${movie.id}_grid',
                  child: CachedNetworkImage(
                    imageUrl: ApiConstants.getPosterUrl(movie.posterPath),
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const LoadingAnimation(size: 80),
                    errorWidget: (context, url, error) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.movie,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.95),
                        ],
                        stops: const [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 12,
                  right: 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  movie.voteAverage.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              movie.releaseYear,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        movie.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
