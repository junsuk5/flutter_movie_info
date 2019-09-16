import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_movie_info/models.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MovieInfoMain(),
    );
  }
}

class MovieInfoMain extends StatefulWidget {
  @override
  _MovieInfoMainState createState() => _MovieInfoMainState();
}

class _MovieInfoMainState extends State<MovieInfoMain> {
  final url =
      'https://api.themoviedb.org/3/movie/upcoming?api_key=a64533e7ece6c72731da47c9c8bc691f&language=ko-KR&page=1';
  final _posterPath = 'https://image.tmdb.org/t/p/w500';

  Result _movieInfoResult;

  List<Results> _filteredResult;

  @override
  void initState() {
    super.initState();

    _loadMovieInfoAsync();
  }

  void _loadMovieInfoAsync() async {
    var response = await http.get(url);
    var jsonResult = json.decode(response.body);

    setState(() {
      _movieInfoResult = Result.fromJson(jsonResult);
      _filteredResult = _movieInfoResult.results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('영화 정보 검색기'),
        ),
        body: _filteredResult != null
            ? Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (text) {
                        setState(() {
                          _filteredResult = _movieInfoResult.results
                              .where((item) => item.title.contains(text))
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '검색',
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredResult.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildItem(_filteredResult[index]);
                      },
                    ),
                  ),
                ],
              )
            : CircularProgressIndicator());
  }

  Padding _buildItem(Results movieInfo) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          children: <Widget>[
            Image.network(
              _posterPath + movieInfo.posterPath,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            Text(
              movieInfo.title,
              style: TextStyle(fontSize: 32),
            ),
          ],
        ),
      ),
    );
  }
}
