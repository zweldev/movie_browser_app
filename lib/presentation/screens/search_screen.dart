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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(
    delay: const Duration(milliseconds: AppConstants.debounceDuration),
  );

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
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

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 2;
    if (width < 600) return 2;
    if (width < 900) return 3;
    return 4;
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 0.65;
    return 0.7;
  }

  double _getSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 12;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    final childAspectRatio = _getChildAspectRatio(context);
    final spacing = _getSpacing(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
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
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state.isLoading) {
            return ShimmerLoading(
              crossAxisCount: crossAxisCount,
            );
          }
          if (state.error != null) {
            return AppErrorWidget(
              message: state.error!,
              onRetry: () => context.read<SearchCubit>().search(state.query),
            );
          }
          if (state.query.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Search for movies',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            );
          }
          if (state.results.isEmpty) {
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
            padding: EdgeInsets.all(spacing),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final movie = state.results[index];
              return MovieCard(
                movie: movie,
                index: index,
                category: MovieCategory.popular,
                onTap: () => _navigateToDetail(movie.id),
              );
            },
          );
        },
      ),
    );
  }
}
