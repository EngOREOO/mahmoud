import 'package:foap/helper/imports/common_import.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../components/post_card.dart';
import '../../controllers/post/post_controller.dart';
import '../../model/post_model.dart';
import '../post/view_post_insight.dart';
import '../settings_menu/notifications.dart';

class Posts extends StatefulWidget {
  final String? hashTag;
  final int? userId;
  final int? locationId;
  final List<PostModel>? posts;
  final int? index;
  final int? page;
  final int? totalPages;

  const Posts(
      {Key? key,
      this.page,
      this.totalPages,
      this.hashTag,
      this.userId,
      this.locationId,
      this.posts,
      this.index})
      : super(key: key);

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final PostController _postController = Get.find();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postController.addPosts(
          widget.posts ?? [], widget.page, widget.totalPages);

      // loadData();
      if (widget.index != null) {
        Future.delayed(const Duration(milliseconds: 200), () {
          itemScrollController.jumpTo(
            index: widget.index!,
          );
        });
      }
    });
  }

  // void loadData() {
  //   if (widget.userId != null) {
  //     PostSearchQuery query = PostSearchQuery();
  //     query.userId = widget.userId!;
  //     _postController.setPostSearchQuery(query: query, callback: () {});
  //   }
  //   if (widget.hashTag != null) {
  //     PostSearchQuery query = PostSearchQuery();
  //     query.hashTag = widget.hashTag!;
  //     _postController.setPostSearchQuery(query: query, callback: () {});
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 55,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ThemeIconWidget(
                  ThemeIcon.backArrow,
                  color: AppColorConstants.iconColor,
                  size: 25,
                ).ripple(() {
                  Get.back();
                }),
                const Spacer(),
                // Image.asset(
                //   'assets/logo.png',
                //   width: 80,
                //   height: 25,
                // ),
                const Spacer(),
                ThemeIconWidget(
                  ThemeIcon.notification,
                  color: AppColorConstants.iconColor,
                  size: 25,
                ).ripple(() {
                  Get.to(() => const NotificationsScreen());
                }),
              ],
            ).hp(20),
            const SizedBox(
              height: 20,
            ),
            Expanded(child: postsView()),
          ],
        ));
  }

  postsView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        _postController.getPosts(() {});
      }
    });

    return GetBuilder<PostController>(
        init: _postController,
        builder: (ctx) {
          List<PostModel> posts = _postController.posts;

          return _postController.postDataWrapper.isLoading.value
              ? const HomeScreenShimmer()
              : posts.isEmpty
                  ? Center(child: BodyLargeText(noDataString.tr))
                  : ScrollablePositionedList.builder(
                      itemScrollController: itemScrollController,
                      itemPositionsListener: itemPositionsListener,
                      padding: const EdgeInsets.only(top: 10, bottom: 50),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        PostModel model = posts[index];
                        return Column(
                          children: [
                            PostCard(
                                model: model,

                                removePostHandler: () {
                                  _postController.removePostFromList(model);
                                },
                                blockUserHandler: () {
                                  _postController
                                      .removeUsersAllPostFromList(model);
                                }),
                            const SizedBox(
                              height: 15,
                            )
                          ],
                        );
                      },
                    );
        });
  }
}
