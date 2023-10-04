import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/story_imports.dart';
import 'package:foap/screens/story/story_view_users.dart';
import 'package:story_view/utils.dart';

import '../profile/my_profile.dart';
import '../profile/other_user_profile.dart';
import '../settings_menu/settings_controller.dart';

class StoryViewer extends StatefulWidget {
  final StoryModel story;
  final VoidCallback storyDeleted;

  const StoryViewer({Key? key, required this.story, required this.storyDeleted})
      : super(key: key);

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  final controller = StoryController();
  final AppStoryController storyController = Get.find();
  final SettingsController settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: storyWidget(),
    );
  }

  Widget storyWidget() {
    return Stack(
      children: [
        StoryView(
            storyItems: [
              for (StoryMediaModel media in widget.story.media.reversed)
                media.isVideoPost() == true
                    ? StoryItem.pageVideo(
                        media.video!,
                        controller: controller,
                        duration: media.videoDuration != null
                            ? Duration(seconds: media.videoDuration! ~/ 1000)
                            : null,
                        key: Key(media.id.toString()),
                      )
                    : StoryItem.pageImage(
                        key: Key(media.id.toString()),
                        url: media.image!,
                        controller: controller,
                      ),
            ],
            controller: controller,
            // pass controller here too
            repeat: true,
            // should the stories be slid forever
            onStoryShow: (s) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                storyController.setCurrentStoryMedia(widget.story.media
                    .where(
                        (element) => Key(element.id.toString()) == s.view.key)
                    .first);
              });
            },
            onComplete: () {
              Get.back();
            },
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) {
                Get.back();
              }
            } // To disable vertical swipe gestures, ignore this parameter.
            // Preferrably for inline story view.
            ),
        Positioned(top: 70, left: 20, right: 0, child: userProfileView()),
        Obx(() => (storyController.currentStoryMediaModel.value?.userId ==
                _userProfileManager.user.value!.id)
            ? Positioned(
                bottom: 20, left: 0, right: 0, child: storyViewCounter())
            : Container()),
        // Positioned(bottom: 0, left: 0, right: 0, child: replyView()),
      ],
    );
  }

  // Widget replyWidget() {
  //   return FooterLayout(
  //     footer: KeyboardAttachable(
  //       // backgroundColor: Colors.blue,
  //       child: Container(
  //         height: 60,
  //         color: AppColorConstants.themeColor,
  //         child: Row(
  //           children: [
  //             Expanded(
  //               child: AppTextField(
  //                 hintText: replyString.tr,
  //               ),
  //             ),
  //             ThemeIconWidget(
  //               ThemeIcon.send,
  //               color: AppColorConstants.iconColor,
  //             )
  //           ],
  //         ).hP25,
  //       ),
  //     ),
  //     child: storyWidget(),
  //   );
  // }

  Widget userProfileView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            AvatarView(
              url: widget.story.image,
              size: 30,
            ).rP8,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BodyMediumText(widget.story.userName,
                    weight: TextWeight.medium, color: Colors.white),
                Obx(() => storyController.currentStoryMediaModel.value != null
                    ? BodyMediumText(
                        storyController.currentStoryMediaModel.value!.createdAt,
                        color: AppColorConstants.grayscale100,
                      )
                    : Container())
              ],
            ),
          ],
        ).ripple(() {
          int userId = widget.story.media.first.userId;
          if (userId == _userProfileManager.user.value!.id) {
            Get.to(() => const MyProfile(showBack: true));
          } else {
            Get.to(() => OtherUserProfile(
                  userId: userId,
                ));
          }
        }),
        const SizedBox(
          width: 50,
        ),
        if (widget.story.media.first.userId ==
            _userProfileManager.user.value!.id)
          SizedBox(
            height: 25,
            width: 40,
            child: const ThemeIconWidget(
              ThemeIcon.more,
              color: Colors.white,
              size: 20,
            ).ripple(() {
              openActionPopup();
            }),
          ).rP25
      ],
    );
  }

  void openActionPopup() {
    controller.pause();

    showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
              children: [
                ListTile(
                    title: Center(child: BodyLargeText(deleteStoryString.tr)),
                    onTap: () async {
                      Get.back();
                      controller.play();

                      storyController.deleteStory(() {
                        widget.storyDeleted();
                      });
                    }),
                divider(),
                ListTile(
                    title: Center(child: BodyLargeText(cancelString.tr)),
                    onTap: () {
                      controller.play();
                      Get.back();
                    }),
              ],
            )).then((value) {
      controller.play();
    });
  }

  Widget storyViewCounter() {
    return Obx(() => storyController.currentStoryMediaModel.value != null
        ? Column(
            children: [
              const ThemeIconWidget(
                ThemeIcon.arrowUp,
                color: Colors.white,
              ),
              const SizedBox(
                height: 5,
              ),
              BodyLargeText(
                '${storyController.currentStoryMediaModel.value!.totalView}',
                color: Colors.white,
              ),
            ],
          ).ripple(() {
            controller.pause();
            Get.bottomSheet(StoryViewUsers()).then((value) {
              controller.play();
            });
          })
        : Container());
  }

// Widget replyView() {
//   return Column(
//     children: [
//       Text(
//         widget.story.title,
//         style: TextStyle(fontSize: FontSizes.b2).bold,
//         textAlign: TextAlign.center,
//       ).hp(DesignConstants.horizontalPadding),
//       divider(height: 0.5, color: AppTheme.dividerColor).tP16,
//     ],
//   );
// }
}
