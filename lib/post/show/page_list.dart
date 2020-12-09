import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_list/post/post.dart';

class PageList extends StatefulWidget {
  @override
  _PageListListState createState() => _PageListListState();
}

class _PageListListState extends State<PageList> {
  final _scroll = ScrollController();
  // PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() => _onScroll(context));
    // _postBloc = context.read<PostBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        switch (state.status) {
          case PostStatus.fail:
            return const Center(child: Text('failed to fetch posts'));
          case PostStatus.success:
            if (state.posts.isEmpty) {
              return const Center(child: Text('no posts'));
            }
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return index >= state.posts.length
                    ? BottomLoader()
                    : PostListItem(post: state.posts[index]);
              },
              itemCount: state.hasReachMax
                  ? state.posts.length
                  : state.posts.length + 1,
              controller: _scroll,
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll(BuildContext context) {
    if (_isBottom) BlocProvider.of<PostBloc>(context).add(PostFetched());
  }

  bool get _isBottom {
    if (!_scroll.hasClients) return false;
    final maxScroll = _scroll.position.maxScrollExtent;
    final currentScroll = _scroll.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
