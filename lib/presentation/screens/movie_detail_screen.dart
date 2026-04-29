import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/constants.dart';
import '../cubit/movie_detail_cubit.dart';
import '../widgets/error_widget.dart';

const Map<int, String> _genreMap = {
  28: 'Action',
  12: 'Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  14: 'Fantasy',
  36: 'History',
  27: 'Horror',
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Science Fiction',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western',
};

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    context.read<MovieDetailCubit>().loadMovieDetails(widget.movieId);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<MovieDetailCubit, MovieDetailState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: Shimmer.fromColors(
              baseColor: colorScheme.surfaceContainerHighest,
              highlightColor: colorScheme.surface,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 400,
                      width: double.infinity,
                      color: colorScheme.surface,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 24,
                            width: 200,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 16,
                            width: 150,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            height: 20,
                            width: 100,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 16,
                            width: 200,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state.error != null) {
          return Scaffold(
            appBar: AppBar(),
            body: AppErrorWidget(
              message: state.error!,
              onRetry: () => context.read<MovieDetailCubit>().loadMovieDetails(
                    widget.movieId,
                  ),
            ),
          );
        }
        final movie = state.movie;
        if (movie == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Movie not found')),
          );
        }
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Scaffold(
            body: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 400,
                      pinned: true,
                      backgroundColor: colorScheme.surface,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Hero(
                              tag: 'movie_poster_${movie.id}',
                              child: CachedNetworkImage(
                                imageUrl:
                                    ApiConstants.getPosterUrl(movie.posterPath),
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  color: colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.movie, size: 64),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  stops: const [0.5, 1.0],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      movie.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  _buildFavoriteButton(state),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildRatingChip(movie.voteAverage),
                                const SizedBox(width: 8),
                                Text(
                                  '(${movie.voteCount} votes)',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(width: 16),
                                if (movie.releaseDate != null &&
                                    movie.releaseDate!.isNotEmpty)
                                  Chip(
                                    label: Text(movie.releaseYear),
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (movie.genreIds.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: movie.genreIds
                                    .map((id) => _genreMap[id])
                                    .where((genre) => genre != null)
                                    .map((genre) => Chip(
                                          label: Text(
                                            genre!,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                          labelPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 4),
                                        ))
                                    .toList(),
                              ),
                            const SizedBox(height: 24),
                            Text(
                              'Overview',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              movie.overview.isNotEmpty
                                  ? movie.overview
                                  : 'No overview available.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteButton(MovieDetailState state) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: state.isFavorite ? 1.2 : 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                state.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: state.isFavorite ? Colors.red : Colors.white,
                size: 28,
              ),
              onPressed: () {
                context.read<MovieDetailCubit>().toggleFavorite();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingChip(double rating) {
    return Chip(
      avatar: Icon(Icons.star, size: 18, color: Colors.amber[700]),
      label: Text(rating.toStringAsFixed(1)),
      visualDensity: VisualDensity.compact,
    );
  }
}
