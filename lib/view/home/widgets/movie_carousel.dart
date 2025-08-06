import 'package:cineverse/models/movie.dart';
import 'package:cineverse/view/home/see_all_page.dart';
import 'package:cineverse/view/home/widgets/movie_card.dart';
import 'package:flutter/material.dart';

class MovieCarousel extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final Future<List<Movie>> seeAllFuture;

  const MovieCarousel({
    super.key,
    required this.title,
    required this.movies,
    required this.seeAllFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeeAllPage(
                        title: title,
                        moviesFuture: seeAllFuture,
                      ),
                    ),
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 16.0 : 8.0,
                  right: index == movies.length - 1 ? 16.0 : 8.0,
                ),
                child: MovieCard(movie: movies[index], width: 140),
              );
            },
          ),
        ),
      ],
    );
  }
}
