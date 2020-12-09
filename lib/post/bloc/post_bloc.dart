import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_list/post/post.dart';
import 'package:http/http.dart' as http;

part 'post_event.dart';
part 'post_state.dart';

int postAmount = 20;

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({@required this.httpClient}) : super(PostState());

  final http.Client httpClient;

  @override
  Stream<PostState> mapEventToState(
    PostEvent event,
  ) async* {
    if (event is PostFetched) {
      yield await MapPostFetchedToState(state);
    }
  }

  Future<PostState> MapPostFetchedToState(PostState state) async {
    if (state.hasReachMax) return state;
    try {
      if (state.status == PostStatus.initial) {
        final posts = await FetchPosts();
        return state.copy(
          status: PostStatus.success,
          posts: posts,
          hasReachMax: HasReachMax(posts.length),
        );
      }
      final posts = await FetchPosts(state.posts.length);
      return posts.isEmpty
          ? state.copy(hasReachMax: true)
          : state.copy(
              status: PostStatus.success,
              posts: List.of(state.posts),
              hasReachMax: HasReachMax(posts.length));
    } on Exception {
      return state.copy(status: PostStatus.fail);
    }
  }

  Future<List<Post>> FetchPosts([int index = 0]) async {
    final response = await httpClient.get(
        'https://jsonplaceholder.typicode.com/posts?_start=$index&_limit=$postAmount');
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List;
      return body.map((dynamic json) {
        return Post(
          id: json['id'] as int,
          title: json['title'] as String,
          body: json['body'] as String,
        );
      }).toList();
    }
  }

  bool HasReachMax(int length) => length < postAmount ? true : false;
}
