import 'package:cineverse/models/movie.dart';
import 'package:cineverse/view/home/widgets/movie_card.dart';
import 'package:flutter/material.dart';

class MovieCarousel extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const MovieCarousel({super.key, required this.title, required this.movies});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carousel Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
        ),
        // Horizontal List of Movies
        SizedBox(
          height: 280, // Set a fixed height for the carousel
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 16.0 : 8.0,
                  right: index == movies.length - 1 ? 16.0 : 8.0,
                ),
                child: MovieCard(movie: movies[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}