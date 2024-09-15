  /// This is the main `HomePage` widget that displays a list of popular movies.
  /// It fetches the movie data from the TMDB API and allows the user to filter the movies by genre.
  /// The movies are displayed in a grid layout, and the user can tap on a movie to navigate to the `MovieDetailsPage`.
  /// The `HomePage` also includes an animated app bar title and a dropdown menu to select the genre filter.
  import 'package:flutter/material.dart';
import 'package:movie_app/search.dart';
  import 'package:tmdb_api/tmdb_api.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:video_player/video_player.dart';

  class HomePage extends StatefulWidget {
    const HomePage({Key? key}) : super(key: key);

    @override
    _HomePageState createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {
    final String apiKey = '52a9aef4e25460869cb1a5a3eb20bd61';
    final String readAccessToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1MmE5YWVmNGUyNTQ2MDg2OWNiMWE1YTNlYjIwYmQ2MSIsIm5iZiI6MTcyNjQyMDE4NC41NTgwMzEsInN1YiI6IjY1NTBlODQxZDRmZTA0MDBmZTAzY2QzZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.dBy_HM5DD8F8bpdtG_RjtYeVEE5PQBp6aWDQuFiEtNI';
    late TMDB tmdb;
    List<dynamic> movies = [];
    String selectedGenre = 'All';
    int _currentIndex = 0;

    final List<String> genres = ['All', 'Action', 'Comedy', 'Drama', 'Sci-Fi', 'Horror'];

    @override
    void initState() {
      super.initState();
      tmdb = TMDB(
        ApiKeys(apiKey, readAccessToken),
        logConfig: ConfigLogger.showAll(),
      );
      fetchMovies();
    }

    Future<void> fetchMovies() async {
      try {
        final result = await tmdb.v3.movies.getPopular();
        setState(() {
          movies = result['results'];
        });
      } catch (e) {
        print('Error fetching movies: $e');
      }
    }

    void _navigateToMovieDetails(BuildContext context, dynamic movie) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MovieDetailsPage(movie: movie, tmdb: tmdb),
        ),
      );
    }

    List<dynamic> getFilteredMovies() {
      if (selectedGenre == 'All') {
        return movies;
      } else {
        return movies.where((movie) {
          List<dynamic> movieGenres = movie['genre_ids'] ?? [];
          return movieGenres.contains(getGenreId(selectedGenre));
        }).toList();
      }
    }

    int getGenreId(String genre) {
      switch (genre) {
        case 'Action':
          return 28;
        case 'Comedy':
          return 35;
        case 'Drama':
          return 18;
        case 'Sci-Fi':
          return 878;
        case 'Horror':
          return 27;
        default:
          return 0;
      }
    }

    @override
    Widget build(BuildContext context) {
      final filteredMovies = getFilteredMovies();

      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: AnimatedDefaultTextStyle(
              duration: Duration(seconds: 2),
              style: GoogleFonts.roboto(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
              child: TweenAnimationBuilder(
                tween: ColorTween(begin: const Color.fromARGB(255, 41, 154, 199), end: const Color.fromARGB(255, 70, 40, 202)),
                duration: Duration(seconds: 3),
                builder: (context, Color? color, child) {
                  return Text(
                    'M o v i i i',
                    style: TextStyle(color: color, letterSpacing: 1.0),
                  );
                },
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedGenre,
                items: genres.map((String genre) {
                  return DropdownMenuItem<String>(
                    value: genre,
                    child: Text(genre),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGenre = newValue!;
                  });
                },
              ),
            ),
            Expanded(
              child: filteredMovies.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filteredMovies.length,
                      itemBuilder: (context, index) {
                        final movie = filteredMovies[index];
                        return GestureDetector(
                          onTap: () => _navigateToMovieDetails(context, movie),
                          child: Card(
                            elevation: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: movie['poster_path'] != null
                                      ? Image.network(
                                          'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )
                                      : Container(
                                          color: Colors.grey,
                                          child: Center(
                                            child: Text('No Image', style: GoogleFonts.roboto()),
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie['title'] ?? 'Unknown Title',
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        movie['release_date'] ?? 'Unknown Date',
                                        style: GoogleFonts.roboto(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (movie['vote_average'] ?? 'No vote').toString(),
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage(tmdb: tmdb)),
              );
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
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