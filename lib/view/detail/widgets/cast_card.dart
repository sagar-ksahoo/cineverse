import 'package:cineverse/models/cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CastCard extends StatelessWidget {
  final Cast castMember;
  const CastCard({super.key, required this.castMember});
  static final String imageBaseUrl = dotenv.env['TMDB_IMAGE_BASE_URL']!;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, 
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: castMember.profilePath != null
                ? Image.network(
                    '$imageBaseUrl${castMember.profilePath}',
                    height: 120,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 120,
                    width: 100,
                    color: Colors.grey[800],
                    child: const Icon(Icons.person, size: 50),
                  ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              castMember.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (castMember.character != null)
            Flexible(
              child: Text(
                castMember.character!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ),
        ],
      ),
    );
  }
}
