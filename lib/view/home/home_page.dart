import 'package:cineverse/view/home/widgets/movie_carousel.dart';
import 'package:cineverse/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repository/movie_repository.dart';

// The HomePage can now be a StatelessWidget since state is managed by the ViewModel.
class HomePage extends StatelessWidget {
  final VoidCallback onSearchTap;
  const HomePage({super.key, required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    // Get the instance of our ViewModel from the provider
    final viewModel = context.watch<HomeViewModel>();
    final repository = MovieRepositoryImpl();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cineverse'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // If the ViewModel is loading, show a spinner. Otherwise, show the content.
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSearchBar(context),
                const SizedBox(height: 20),
                // Pass the real data from the ViewModel to the carousel
                MovieCarousel(
                  title: 'Trending Movies',
                  movies: viewModel.trendingMovies,
                  seeAllFuture:
                      repository.getTrendingMovies(), // Pass the future
                ),
                const SizedBox(height: 20),
                MovieCarousel(
                  title: 'Now Playing',
                  movies: viewModel.nowPlayingMovies,
                  seeAllFuture:
                      repository.getNowPlayingMovies(), // Pass the future
                ),
                const SizedBox(height: 20),
                MovieCarousel(
                  title: 'Popular Movies',
                  movies: viewModel
                      .popularMovies, // We'll add this to the ViewModel next
                  seeAllFuture: repository.getPopularMovies(),
                ),
                const SizedBox(height: 20),
                MovieCarousel(
                  title: 'Top Rated Movies',
                  movies: viewModel
                      .topRatedMovies, // We'll add this to the ViewModel next
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
                // 1. Wrap the Text widget in an Expanded widget
                Expanded(
                  child: Text(
                    'Search for shows, movies, people...',
                    // 2. Add these properties for better text handling
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
