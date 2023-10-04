import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/hashtag_tile.dart';
import '../../helper/imports/common_import.dart';
import '../../controllers/post/add_post_controller.dart';

class TagHashtagView extends StatelessWidget {
  TagHashtagView({
    Key? key,
  }) : super(key: key);

  final AddPostController addPostController = Get.find();

  final RefreshController _hashtagRefreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
          padding: EdgeInsets.only(
              left: DesignConstants.horizontalPadding,
              right: DesignConstants.horizontalPadding),
          itemCount: addPostController.hashTags.length,
          itemBuilder: (BuildContext ctx, int index) {
            return HashTagTile(
              hashtag: addPostController.hashTags[index],
              onItemCallback: () {
                addPostController
                    .addHashTag(addPostController.hashTags[index].name);
              },
            );
          },
        ).addPullToRefresh(
            refreshController: _hashtagRefreshController,
            onRefresh: () {},
            onLoading: () {
              addPostController.searchHashTags(
                  text: addPostController.currentHashtag.value,
                  callBackHandler: () {
                    _hashtagRefreshController.loadComplete();
                  });
            },
            enablePullUp: true,
            enablePullDown: false));

  }
}
