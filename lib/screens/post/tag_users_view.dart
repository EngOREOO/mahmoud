import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../components/user_card.dart';
import '../../helper/imports/common_import.dart';
import '../../controllers/misc/users_controller.dart';
import '../../controllers/post/add_post_controller.dart';

class TagUsersView extends StatelessWidget {
  TagUsersView({
    Key? key,
  }) : super(key: key);

  final AddPostController addPostController = Get.find();
  final UsersController _usersController = Get.find();

  final RefreshController _usersRefreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _hashtagRefreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.separated(
        padding: EdgeInsets.only(
            top: 20,
            left: DesignConstants.horizontalPadding,
            right: DesignConstants.horizontalPadding),
        itemCount: _usersController.searchedUsers.length,
        itemBuilder: (BuildContext ctx, int index) {
          return UserTile(
            profile: _usersController.searchedUsers[index],
            viewCallback: () {
              addPostController
                  .addUserTag(_usersController.searchedUsers[index].userName);
            },
          );
        },
        separatorBuilder: (BuildContext ctx, int index) {
          return const SizedBox(
            height: 20,
          );
        }).addPullToRefresh(
        refreshController: _usersRefreshController,
        onRefresh: () {},
        onLoading: () {
          addPostController.searchUsers(
              text: addPostController.currentUserTag.value,
              callBackHandler: () {
                _usersRefreshController.loadComplete();
              });
        },
        enablePullUp: true,
        enablePullDown: false));
  }
}
