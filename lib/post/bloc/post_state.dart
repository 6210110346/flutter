part of 'post_bloc.dart';

enum PostStatus { initial, success, fail }

class PostState extends Equatable {
  PostState(
      {this.status = PostStatus.initial,
      this.posts = const <Post>[],
      this.hasReachMax = false});

  final PostStatus status;
  final List<Post> posts;
  final bool hasReachMax;

  PostState copy({
    PostStatus status,
    List<Post> posts,
    bool hasReachMax,
  }) {
    return PostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      hasReachMax: hasReachMax ?? this.hasReachMax,
    );
  }

  @override
  List<Object> get props => [status, posts, hasReachMax];
}
