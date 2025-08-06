import 'package:cineverse/models/movie.dart';
import 'package:cineverse/repository/movie_repository.dart';
import 'package:cineverse/view/detail/movie_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SavedMoviesPage extends StatefulWidget {
  const SavedMoviesPage({super.key});

  @override
  State<SavedMoviesPage> createState() => _SavedMoviesPageState();
}

class _SavedMoviesPageState extends State<SavedMoviesPage> {
  final MovieRepository _repository = MovieRepositoryImpl();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlist'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Movie>>(
        future: _repository.getBookmarkedMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final movies = snapshot.data!;

            if (movies.isEmpty) {
              return const Center(child: Text("Your watchlist is empty."));
            }

            return ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(
                  leading: movie.posterPath != null
                      ? Image.network(
                          '${dotenv.env['TMDB_IMAGE_BASE_URL']!}${movie.posterPath}',
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.movie, size: 50),
                  title: Text(movie.title),
                  subtitle: Text(movie.year),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailPage(movie: movie),
                      ),
                    ).then((_) => setState(() {}));
                  },
                );
              },
            );
          } else {
            return const Center(child: Text("No movies found."));
          }
        },
      ),
    );
  }
}
