


import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app/helpers/debouncer.dart';
import 'package:movies_app/models/models.dart';


class MoviesProvider extends ChangeNotifier{

  final String _apiKey = '29ca4e9a1597c9efe0146c3c66c7c98b';
  final String _baseUrl = 'api.themoviedb.org';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  int _popularPage = 0;

  Map<int, List<Cast>> moviesCasting = {};

  final debouncer = Debouncer(
    duration: const Duration(milliseconds: 500),
  );


  final StreamController<List<Movie>> _suggestionStreamController = StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream => this._suggestionStreamController.stream;

  MoviesProvider(){
    getOnDisplayMovies();
    getPopularMovies();

  }

  Future<String> _getJsonData( String endpoint, [int page = 1]) async{
    var url = Uri.https(_baseUrl, endpoint,{
      'api_key': _apiKey,
      'language': _language,
      'page' : '$page'      
    });

    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async{

   /*  var url = Uri.https(_baseUrl, '3/movie/now_playing',{
      'api_key': _apiKey,
      'language': _language,
      'page' : '1'      
    });

    final response = await http.get(url); */

    final jsonData = await _getJsonData('3/movie/now_playing');


    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getPopularMovies() async{
    /* var url = Uri.https(_baseUrl, '3/movie/popular',{
      'api_key': _apiKey,
      'language': _language,
      'page' : '1'      
    });

    final response = await http.get(url); */

    _popularPage++;

    final jsonData = await _getJsonData('3/movie/popular', _popularPage);

    final popularResponse = PopularResponse.fromJson(jsonData);
    popularMovies = [ ...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async{

    if(moviesCasting.containsKey(movieId))return moviesCasting[movieId]!;

    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);


    moviesCasting[movieId] = creditsResponse.cast;

    return creditsResponse.cast;

  }

  Future<List<Movie>> searchMovie(String query) async{

    final url = Uri.https(_baseUrl, '3/search/movie',{
      'api_key': _apiKey,
      'language': _language,
      'query': query 
    });

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;
  }

  void getSuggestionsByQuery(String query){
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await searchMovie(value);
      _suggestionStreamController.add(results);
    };

    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) { 
      debouncer.value = query;
    });

    Future.delayed(const Duration(milliseconds: 301)).then((_) => timer.cancel());

  }

}