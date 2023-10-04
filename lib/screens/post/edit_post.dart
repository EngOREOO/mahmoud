import 'package:foap/helper/imports/models.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/post/tag_hashtag_view.dart';
import 'package:foap/screens/post/tag_users_view.dart';
import '../../controllers/post/add_post_controller.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel post;

  const EditPostScreen({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  EditPostScreenState createState() => EditPostScreenState();
}

class EditPostScreenState extends State<EditPostScreen> {
  TextEditingController descriptionText = TextEditingController();
  final AddPostController addPostController = Get.find();

  @override
  void initState() {
    addPostController.textChanged(widget.post.title, widget.post.title.length);
    descriptionText.text = widget.post.title;
    super.initState();
  }

  @override
  void dispose() {
    descriptionText.text = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GetBuilder<AddPostController>(
          init: addPostController,
          builder: (ctx) {
            return Stack(
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 55,
                      ),
                      Row(
                        children: [
                          InkWell(
                              onTap: () {
                                Get.back();
                                addPostController.clear();
                              },
                              child:
                                  const ThemeIconWidget(ThemeIcon.backArrow)),
                          const Spacer(),
                          Container(
                                  color: AppColorConstants.themeColor,
                                  child: BodyLargeText(
                                    updateString.tr,
                                    weight: TextWeight.medium,
                                    color: Colors.white,
                                  ).setPadding(
                                      left: 8, right: 8, top: 5, bottom: 5))
                              .round(10)
                              .ripple(() {
                            if (descriptionText.text.isNotEmpty) {
                              addPostController.updatePost(
                                  allowComments:
                                      addPostController.enableComments.value,
                                  title: descriptionText.text,
                                  postId: widget.post.id);
                            }
                          }),
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 30,
                      ),
                      addDescriptionView()
                          .hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          BodyMediumText(
                            allowCommentsString.tr,
                            weight: TextWeight.semiBold,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Obx(() => ThemeIconWidget(
                                      addPostController.enableComments.value
                                          ? ThemeIcon.selectedCheckbox
                                          : ThemeIcon.emptyCheckbox)
                                  .ripple(() {
                                addPostController.toggleEnableComments();
                              })),
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color:
                              AppColorConstants.disabledColor.withOpacity(0.1),
                          child: addPostController.currentHashtag.isNotEmpty
                              ? TagHashtagView()
                              : addPostController.currentUserTag.isNotEmpty
                                  ? TagUsersView()
                                  : Container().ripple(() {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    }),
                        ),
                      ),
                      Obx(() => addPostController.isEditing.value == 0
                          ? const Spacer()
                          : Container()),
                    ]),
              ],
            );
          }),
    );
  }

  Widget addDescriptionView() {
    return SizedBox(
      height: 100,
      child: Obx(() {
        descriptionText.value = TextEditingValue(
            text: addPostController.searchText.value,
            selection: TextSelection.fromPosition(
                TextPosition(offset: addPostController.position.value)));

        return Focus(
          child: Container(
            color: AppColorConstants.cardColor,
            child: TextField(
              controller: descriptionText,
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: FontSizes.h5,
                  color: AppColorConstants.grayscale900),
              maxLines: 5,
              onChanged: (text) {
                addPostController.textChanged(
                    text, descriptionText.selection.baseOffset);
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.only(top: 10, left: 10, right: 10),
                  counterText: "",
                  hintStyle: TextStyle(
                      fontSize: FontSizes.h5,
                      color: AppColorConstants.grayscale500),
                  hintText: addSomethingAboutPostString.tr),
            ),
          ).round(10),
          onFocusChange: (hasFocus) {
            if (hasFocus == true) {
              addPostController.startedEditing();
            } else {
              addPostController.stoppedEditing();
            }
          },
        );
      }),
    );
  }
}
