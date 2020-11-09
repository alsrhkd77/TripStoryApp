import 'package:trip_story/Provider/post_provider.dart';
import 'package:trip_story/models/post.dart';

class ViewPostHandler{
  final _postProvider = PostProvider();

  Future<Post> fetchViewPost(postId) => _postProvider.fetchPostView(postId);
}