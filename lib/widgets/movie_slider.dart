import 'package:flutter/material.dart';
import 'package:movies_app/models/models.dart';

class MovieSlider extends StatefulWidget {
  final String? title;
  final List<Movie> movies;
  final Function onNextPage;

  const MovieSlider(
      {super.key, this.title, required this.movies, required this.onNextPage});

  @override
  State<MovieSlider> createState() => _MovieSliderState();
}

class _MovieSliderState extends State<MovieSlider> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {

      if (scrollController.position.pixels >=
          (scrollController.position.maxScrollExtent - 500)) {
            widget.onNextPage();
          }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      height: 280,
      /* alignment: AlignmentDirectional.topStart, */
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null && widget.title != '')
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  widget.title!,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                )),
          _MoviePoster(
              movies: widget.movies, scrollController: scrollController)
        ],
      ),
    );
  }
}

class _MoviePoster extends StatelessWidget {
  final List<Movie> movies;
  final ScrollController scrollController;

  const _MoviePoster({
    Key? key,
    required this.movies,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (_, index) {
          final Movie movie = movies[index];

          movie.heroId = 'slider-${movie.id}';

          return Container(
            width: 130,
            height: 190,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, 'details',
                      arguments: movie),
                  child: Hero(
                    tag: movie.heroId!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FadeInImage(
                        placeholder: const AssetImage('assets/loading.gif'),
                        image: NetworkImage(movie.fullPosterImg),
                        width: 130,
                        height: 190,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  movie.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
