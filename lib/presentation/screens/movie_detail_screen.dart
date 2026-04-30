import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/constants.dart';
import '../cubit/movie_detail_cubit.dart';
import '../widgets/error_widget.dart';
import '../widgets/theme_toggle_button.dart';
import 'image_viewer_screen.dart';

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
  final VoidCallback toggleTheme;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
    required this.toggleTheme,
  });

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
            body: Center(
              child: Text(
                'Movie not found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
        }
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Scaffold(
            backgroundColor: colorScheme.surface,
            body: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ImageViewerScreen(
                            imageUrl:
                                ApiConstants.getPosterUrl(movie.posterPath),
                            heroTag: 'movie_poster_${movie.id}',
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'movie_poster_${movie.id}',
                      child: CachedNetworkImage(
                        imageUrl: ApiConstants.getPosterUrl(movie.posterPath),
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.movie,
                            size: 64,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                Colors.black.withValues(alpha: 0.25),
                                Colors.black.withValues(alpha: 0.45),
                                Colors.black.withValues(alpha: 0.75),
                                Colors.black.withValues(alpha: 0.95),
                              ]
                            : [
                                Colors.black.withValues(alpha: 0.08),
                                Colors.black.withValues(alpha: 0.12),
                                Colors.black.withValues(alpha: 0.18),
                                Colors.black.withValues(alpha: 0.26),
                              ],
                        stops: const [0.0, 0.35, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        _buildTopCircleButton(
                          icon: Icons.chevron_left_rounded,
                          onTap: () => Navigator.of(context).pop(),
                          isDark: isDark,
                        ),
                        const Spacer(),
                        ThemeToggleButton(onPressed: widget.toggleTheme),
                        const SizedBox(width: 8),
                        _buildFavoriteButton(state),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.42,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.55)
                          : colorScheme.surface.withValues(alpha: 0.95),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : colorScheme.outlineVariant.withValues(alpha: 0.7),
                        width: 0.7,
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRatingRow(movie),
                          const SizedBox(height: 14),
                          Text(
                            movie.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (movie.genreIds.isNotEmpty)
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: movie.genreIds
                                  .map((id) => _genreMap[id])
                                  .where((genre) => genre != null)
                                  .map((genre) => _buildGenreChip(genre!))
                                  .toList(),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            movie.overview.isNotEmpty
                                ? movie.overview
                                : 'No overview available.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: isDark ? 0.82 : 0.9,
                              ),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (movie.releaseDate != null &&
                              movie.releaseDate!.isNotEmpty)
                            _buildMetadataItem(
                              Icons.calendar_today_outlined,
                              movie.releaseYear,
                              isDark: isDark,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteButton(MovieDetailState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: state.isFavorite ? 1.2 : 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surface.withValues(alpha: 0.3)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : colorScheme.outlineVariant.withValues(alpha: 0.7),
                width: 0.6,
              ),
            ),
            child: IconButton(
              icon: Icon(
                state.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: state.isFavorite ? Colors.red : colorScheme.onSurface,
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

  Widget _buildRatingRow(dynamic movie) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.45),
                    ]
                  : [
                      colorScheme.surfaceContainerHighest,
                      colorScheme.surfaceContainer,
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.22)
                  : colorScheme.outlineVariant.withValues(alpha: 0.8),
              width: 0.7,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'IMDb',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.amber[500],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Icon(Icons.star_rounded, size: 18, color: Colors.amber[500]),
        const SizedBox(width: 4),
        Text(
          movie.voteAverage.toStringAsFixed(1),
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(${movie.voteCount} reviews)',
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataItem(
    IconData icon,
    String text, {
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: isDark ? 0.75 : 0.65,
              ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: isDark ? 0.75 : 0.65,
                    ),
              ),
        ),
      ],
    );
  }

  Widget _buildGenreChip(String genre) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.18)
              : colorScheme.outlineVariant.withValues(alpha: 0.75),
          width: 0.6,
        ),
      ),
      child: Text(
        genre,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: isDark ? 0.9 : 0.85),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTopCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : colorScheme.surface.withValues(alpha: 0.95),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.25)
              : colorScheme.outlineVariant.withValues(alpha: 0.7),
          width: 0.6,
        ),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: colorScheme.onSurface),
        splashRadius: 20,
      ),
    );
  }
}
