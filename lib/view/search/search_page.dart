import 'package:cineverse/models/movie.dart';
import 'package:cineverse/view/detail/movie_detail_page.dart';
import 'package:cineverse/viewmodel/search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    // Clear previous results when the page is first loaded.
    Provider.of<SearchViewModel>(context, listen: false).clearResults();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SearchViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Movies'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (query) {
                // This now calls the debouncing method in the ViewModel
                viewModel.onSearchChanged(query);
              },
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search for a movie...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: viewModel.results.length,
                    itemBuilder: (context, index) {
                      final movie = viewModel.results[index];
                      return ListTile(
                        leading: movie.posterPath != null
                            ? Image.network(
                                '${dotenv.env['TMDB_IMAGE_BASE_URL']!}${movie.posterPath}',
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error, size: 50),
                              )
                            : const Icon(Icons.movie, size: 50),
                        title: Text(movie.title),
                        subtitle: Text(movie.year),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailPage(movie: movie),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
