
import 'package:flutter/material.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class SearchPage extends StatefulWidget {
  final TMDB tmdb;

  const SearchPage({Key? key, required this.tmdb}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> searchResults = [];
  TextEditingController _searchController = TextEditingController();

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    try {
      final result = await widget.tmdb.v3.search.queryMovies(query);
      setState(() {
        searchResults = result['results'];
      });
    } catch (e) {
      print('Error searching movies: $e');
    }
  }

  void _navigateToMovieDetails(BuildContext context, dynamic movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsPage(movie: movie, tmdb: widget.tmdb),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Movies', style: GoogleFonts.roboto()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for movies...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                _searchMovies(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final movie = searchResults[index];
                return ListTile(
                  leading: movie['poster_path'] != null
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w92${movie['poster_path']}',
                          width: 50,
                          height: 75,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 50,
                          height: 75,
                          color: Colors.grey,
                          child: Icon(Icons.movie),
                        ),
                  title: Text(
                    movie['title'] ?? 'Unknown Title',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    movie['release_date'] ?? 'Unknown Date',
                    style: GoogleFonts.roboto(),
                  ),
                  onTap: () => _navigateToMovieDetails(context, movie),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MovieDetailsPage extends StatefulWidget {
  final dynamic movie;
  final TMDB tmdb;

  const MovieDetailsPage({Key? key, required this.movie, required this.tmdb}) : super(key: key);

  @override
  _MovieDetailsPageState createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  late VideoPlayerController _controller;
  String? _videoKey;

  @override
  void initState() {
    super.initState();
    _fetchMovieVideos();
  }

  Future<void> _fetchMovieVideos() async {
    try {
      final result = await widget.tmdb.v3.movies.getVideos(widget.movie['id']);
      final videos = result['results'] as List;
      if (videos.isNotEmpty) {
        setState(() {
          _videoKey = videos.first['key'];
        });
        _initializeVideoPlayer();
      }
    } catch (e) {
      print('Error fetching movie videos: $e');
    }
  }

  void _initializeVideoPlayer() {
    if (_videoKey != null) {
      _controller = VideoPlayerController.network(
        'https://www.youtube.com/watch?v=$_videoKey',
      )..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie['title'], style: GoogleFonts.roboto()),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_videoKey != null && _controller.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            else
              Center(child: CircularProgressIndicator()),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie['title'],
                    style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Release Date: ${widget.movie['release_date']}',
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rating: ${widget.movie['vote_average']}',
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.movie['overview'],
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _videoKey != null
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}
