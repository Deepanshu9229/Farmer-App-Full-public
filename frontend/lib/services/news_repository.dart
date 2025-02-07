import 'dart:convert';

import 'package:frontend/models/news_channel_headlines_model.dart';
import 'package:http/http.dart' as http;

class NewsRepository {

  Future<NewsChannelHeadlinesModel> fetchNewsChannelHeadlinesApi() async{

   // String url = 'https://newsapi.org/v2/top-headlines?sources=google-news-us&apiKey=aeaf09a51a02439b9b6e7ab182418971';
  String url = 'https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=aeaf09a51a02439b9b6e7ab182418971';

    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
      final body = jsonDecode(response.body);
      return NewsChannelHeadlinesModel.fromJson(body);
    }
    throw Exception('Error');

  }

}