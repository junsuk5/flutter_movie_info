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
        primarySwatch: Colors.blueGrey,
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
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          title: Text('영화 정보 검색기'),
        ),
        body: _filteredResult != null
            ? Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
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
                    child: GridView.builder(
                      itemCount: _filteredResult.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildItem(_filteredResult[index]);
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, childAspectRatio: 1 / 1.9),
                    ),
                  ),
                ],
              )
            : CircularProgressIndicator());
  }

  Widget _buildItem(Results movieInfo) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(movieInfo)),
        );
      },
      child: Column(
        children: <Widget>[
          Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Hero(
              tag: movieInfo.posterPath,
              child: Image.network(
                _posterPath + movieInfo.posterPath,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                movieInfo.title,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Results results;

  DetailPage(this.results);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(results.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  results.title,
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: results.posterPath,
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500' + results.posterPath,
                        height: 300,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('개봉일 : ${results.releaseDate}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Card(
                                elevation: 5,
                                color: Colors.blue,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        ' ${results.voteCount}',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                elevation: 5,
                                color: Colors.blue,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    '★ ${results.voteAverage}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Divider(),
                Text(results.overview),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
