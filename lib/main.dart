import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

class MovieBrowserApp extends StatelessWidget {
  final MovieRepository movieRepository;

  const MovieBrowserApp({super.key, required this.movieRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MovieListCubit>(
          create: (_) => MovieListCubit(movieRepository),
        ),
        BlocProvider<MovieDetailCubit>(
          create: (_) => MovieDetailCubit(movieRepository),
        ),
        BlocProvider<FavoritesCubit>(
          create: (_) => FavoritesCubit(movieRepository),
        ),
        BlocProvider<SearchCubit>(create: (_) => SearchCubit(movieRepository)),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MovieListScreen(),
    SearchScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 2) {
            context.read<FavoritesCubit>().loadFavorites();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Movies',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
