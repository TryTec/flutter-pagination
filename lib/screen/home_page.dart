import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scrollController = ScrollController();
  bool isLoadingMore = false;
  List posts = [];
  int page = 1;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text('Pagination'),
        centerTitle: true,
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(12.0),
          controller: scrollController,
          itemCount: isLoadingMore ? posts.length + 1 : posts.length,
          itemBuilder: (context, index) {
            if (index < posts.length) {
              final post = posts[index];
              final title = post['yoast_head_json']['title'];
              final description = post['yoast_head_json']['description'];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    '$title',
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    '$description',
                    maxLines: 2,
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Future<void> fetchPosts() async {
    final url =
        'https://techcrunch.com/wp-json/wp/v2/posts?context=embed&per_page=10&page=$page';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      setState(() {
        posts += json;
      });
    } else {
      print('Unexpected response');
    }
  }

  Future<void> _scrollListener() async {
    if (isLoadingMore) return;
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      setState(() {
        isLoadingMore = true;
      });
      page += 1;
      await fetchPosts();
      setState(() {
        isLoadingMore = false;
      });
    }
  }
}
