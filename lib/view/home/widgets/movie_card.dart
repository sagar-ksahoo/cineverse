import 'package:cineverse/models/movie.dart';
import 'package:cineverse/view/detail/movie_detail_page.dart'; // 1. Import the new page
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  static final String imageBaseUrl = dotenv.env['TMDB_IMAGE_BASE_URL']!;

  @override
  Widget build(BuildContext context) {
    // 2. Wrap the SizedBox in an InkWell to make it tappable
    return InkWell(
      onTap: () {
        // 3. The navigation action
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailPage(movie: movie),
          ),
        );
      },
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... The rest of the code (Stack, Row, Text) is exactly the same
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: movie.posterPath != null
                      ? Image.network(
                          '$imageBaseUrl${movie.posterPath}',
                          height: 200,
                          width: 140,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              width: 140,
                              color: Colors.grey[800],
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              width: 140,
                              color: Colors.grey[800],
                              child: const Icon(Icons.error),
                            );
                          },
                        )
                      : Container(
                          height: 200,
                          width: 140,
                          color: Colors.grey[800],
                          child: const Icon(Icons.movie, color: Colors.white, size: 50),
                        ),
                ),
                const Positioned(
                  top: 8,
                  left: 8,
                  child: Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(movie.rating.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              movie.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              movie.year,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}