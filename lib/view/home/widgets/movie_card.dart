import 'package:cineverse/models/movie.dart';
import 'package:cineverse/view/detail/movie_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final double? width;

  const MovieCard({super.key, required this.movie, this.width});

  static final String imageBaseUrl = dotenv.env['TMDB_IMAGE_BASE_URL']!;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailPage(movie: movie),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: movie.posterPath != null
                      ? Image.network(
                          '$imageBaseUrl${movie.posterPath}',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey[800],
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[800],
                              child: const Icon(Icons.error),
                            );
                          },
                        )
                      : Container(
                          height: 200,
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
            // Use Flexible to ensure the text section doesn't overflow.
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  // Use MainAxisSize.min to make the column only as tall as its children.
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
            ),
          ],
        ),
      ),
    );
  }
}
