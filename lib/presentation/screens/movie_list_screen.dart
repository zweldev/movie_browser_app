import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
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

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    bool isLoading,
    bool isEmpty,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = screenWidth < 600 ? 12.0 : 16.0;
    final headerHeight = screenWidth < 600 ? 24.0 : 28.0;
    final fontSize = screenWidth < 600 ? 20.0 : 24.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing + 4,
        screenWidth < 600 ? 16 : 24,
        spacing + 4,
        screenWidth < 600 ? 8 : 12,
      ),
      child: isLoading && isEmpty
          ? _buildShimmerHeader(headerHeight, 100)
          : Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
            ),
    );
  }

  Widget _buildShimmerHeader(double height, double width) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth < 600 ? 40 : 60,
      child: Center(
        child: SizedBox(
          width: screenWidth < 600 ? 16 : 20,
          height: screenWidth < 600 ? 16 : 20,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildMovieItem(
    BuildContext context,
    int index,
    List<dynamic> movies,
    double itemWidth,
    double spacing,
    MovieCategory category,
  ) {
    if (index >= movies.length) {
      return _buildLoadingMoreIndicator(context);
    }
    final movie = movies[index];
    return Container(
      width: itemWidth,
      margin: EdgeInsets.only(right: spacing),
      child: MovieCard(
        movie: movie,
        index: index,
        category: category,
        onTap: () => _navigateToDetail(movie.id),
      ),
    );
  }

  Widget _buildHorizontalMovieList({
    required BuildContext context,
    required List<dynamic> movies,
    required MovieCategory category,
    required double height,
    required double itemWidth,
    required double spacing,
    required bool isLoadingMore,
  }) {
    return SizedBox(
      height: height,
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
          itemCount: movies.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) => _buildMovieItem(
            context,
            index,
            movies,
            itemWidth,
            spacing,
            category,
          ),
        ),
      ),
    );
  }

  Widget _buildPopularSection(BuildContext context) {
    return BlocBuilder<MovieListCubit, MovieListState>(
      builder: (context, state) {
        final movies = state.getMoviesByCategory(MovieCategory.popular);
        final screenWidth = MediaQuery.of(context).size.width;
        final spacing = screenWidth < 600 ? 12.0 : 16.0;
        final itemWidth = screenWidth - (spacing * 2);
        final height = itemWidth * 1.5;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                context, 'Popular', state.isLoading, movies.isEmpty),
            if (state.isLoading && movies.isEmpty)
              HorizontalShimmerLoading(
                height: height,
                itemWidth: itemWidth,
                spacing: spacing,
              )
            else if (state.error != null && movies.isEmpty)
              _buildErrorWidget(state.error!, MovieCategory.popular, height)
            else if (movies.isEmpty)
              _buildEmptyWidget(height)
            else
              _buildHorizontalMovieList(
                context: context,
                movies: movies,
                category: MovieCategory.popular,
                height: height,
                itemWidth: itemWidth,
                spacing: spacing,
                isLoadingMore: state.isLoadingMore,
              ),
          ],
        );
      },
    );
  }

  Widget _buildErrorWidget(
      String error, MovieCategory category, double height) {
    return SizedBox(
      height: height,
      child: Center(
        child: AppErrorWidget(
          message: error,
          onRetry: () => context.read<MovieListCubit>().loadMovies(
                category,
                refresh: true,
              ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(double height) {
    return SizedBox(
      height: height,
      child: Center(
        child: Text(
          'No movies found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
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
        final sectionHeight = cardWidth / childAspectRatio;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                context, title, state.isLoading, movies.isEmpty),
            if (state.isLoading && movies.isEmpty)
              HorizontalShimmerLoading(
                height: sectionHeight,
                itemWidth: cardWidth,
                spacing: spacing,
              )
            else if (state.error != null && movies.isEmpty)
              _buildErrorWidget(state.error!, category, sectionHeight)
            else if (movies.isEmpty)
              _buildEmptyWidget(sectionHeight)
            else
              _buildHorizontalMovieList(
                context: context,
                movies: movies,
                category: category,
                height: sectionHeight,
                itemWidth: cardWidth,
                spacing: spacing,
                isLoadingMore: state.isLoadingMore,
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
