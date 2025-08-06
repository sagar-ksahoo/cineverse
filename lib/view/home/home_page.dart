import 'package:cineverse/repository/movie_repository.dart';
import 'package:cineverse/view/home/widgets/movie_carousel.dart';
import 'package:cineverse/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onSearchTap;
  const HomePage({super.key, required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    // Get the instance of our ViewModel from the provider.
    final viewModel = context.watch<HomeViewModel>();
    // We also need a repository instance to pass the futures to the carousel.
    final repository = MovieRepositoryImpl();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cineverse'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // We no longer need to check for isLoading.
      // The ListView will build immediately with cached data,
      // and then rebuild automatically when fresh data arrives.
      body: ListView(
        children: [
          _buildSearchBar(context),
          const SizedBox(height: 20),
          MovieCarousel(
            title: 'Trending Movies',
            movies: viewModel.trendingMovies,
            seeAllFuture: repository.getTrendingMovies(),
          ),
          const SizedBox(height: 20),
          MovieCarousel(
            title: 'Now Playing',
            movies: viewModel.nowPlayingMovies,
            seeAllFuture: repository.getNowPlayingMovies(),
          ),
          const SizedBox(height: 20),
          MovieCarousel(
            title: 'Popular Movies',
            movies: viewModel.popularMovies,
            seeAllFuture: repository.getPopularMovies(),
          ),
          const SizedBox(height: 20),
          MovieCarousel(
            title: 'Top Rated Movies',
            movies: viewModel.topRatedMovies,
            seeAllFuture: repository.getTopRatedMovies(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(30.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(30.0),
          onTap: onSearchTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Search for shows, movies, people...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[400]),
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
