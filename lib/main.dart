import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/constants.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/movie_local_datasource.dart';
import 'data/datasources/movie_remote_datasource.dart';
import 'data/repositories/movie_repository_impl.dart';
import 'domain/repositories/movie_repository.dart';
import 'presentation/cubit/favorites_cubit.dart';
import 'presentation/cubit/movie_detail_cubit.dart';
import 'presentation/cubit/movie_list_cubit.dart';
import 'presentation/cubit/search_cubit.dart';
import 'presentation/screens/favorites_screen.dart';
import 'presentation/screens/movie_list_screen.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/widgets/custom_bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();

  final apiClient = ApiClient();
  final remoteDataSource = MovieRemoteDataSource(apiClient);
  final localDataSource = MovieLocalDataSource();
  await localDataSource.init();

  final movieRepository = MovieRepositoryImpl(
    remoteDataSource,
    localDataSource,
  );

  runApp(MovieBrowserApp(movieRepository: movieRepository));
}

class MovieBrowserApp extends StatefulWidget {
  final MovieRepository movieRepository;

  const MovieBrowserApp({super.key, required this.movieRepository});

  @override
  State<MovieBrowserApp> createState() => _MovieBrowserAppState();
}

class _MovieBrowserAppState extends State<MovieBrowserApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MovieListCubit>(
          create: (_) => MovieListCubit(widget.movieRepository),
        ),
        BlocProvider<MovieDetailCubit>(
          create: (_) => MovieDetailCubit(widget.movieRepository),
        ),
        BlocProvider<FavoritesCubit>(
          create: (_) => FavoritesCubit(widget.movieRepository),
        ),
        BlocProvider<SearchCubit>(
            create: (_) => SearchCubit(widget.movieRepository)),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: HomeScreen(toggleTheme: _toggleTheme),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomeScreen({super.key, required this.toggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    MovieListScreen(toggleTheme: widget.toggleTheme),
    SearchScreen(toggleTheme: widget.toggleTheme),
    FavoritesScreen(toggleTheme: widget.toggleTheme),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: isWide
                        ? constraints.maxWidth * 0.5
                        : constraints.maxWidth,
                    child: CustomBottomNavBar(
                      selectedIndex: _currentIndex,
                      onDestinationSelected: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                        if (index == 2) {
                          context.read<FavoritesCubit>().loadFavorites();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
