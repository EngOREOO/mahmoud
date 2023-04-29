import 'dart:io';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import '../../apiHandler/api_controller.dart';
import '../../model/post_model.dart';
import '../profile/other_user_profile.dart';
import 'comments_screen.dart';

class EnlargeImageViewScreen extends StatefulWidget {
  final PostModel model;
  final VoidCallback? handler;

  const EnlargeImageViewScreen({Key? key, required this.model, this.handler})
      : super(key: key);

  @override
  EnlargeImageViewState createState() => EnlargeImageViewState();
}

class EnlargeImageViewState extends State<EnlargeImageViewScreen> {
  late PostModel? model;
  late File file;

  @override
  void initState() {
    super.initState();
    model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ThemeIconWidget(
                      ThemeIcon.backArrow,
                      size: 20,
                    ).ripple(() {
                      Get.back();
                    }),
                    const Spacer(),
                    model == null
                        ? Container()
                        : Heading6Text(
                                model!.isReported
                                    ? LocalizationString.reported
                                    : LocalizationString.report,
                                weight: TextWeight.medium)
                            .ripple(() {
                            openReportPostPopup();
                          }),
                  ],
                ),
                model == null
                    ? Container()
                    : Positioned(
                        left: 0,
                        right: 0,
                        child: Center(
                          child: InkWell(
                              onTap: () {
                                Get.to(() =>
                                    OtherUserProfile(userId: model!.user.id));
                              },
                              child: Heading5Text(
                                model!.user.userName,
                                weight: TextWeight.medium,
                              )),
                        ),
                      ),
              ],
            ).hP16,
            divider(context: context).vP8,
            Expanded(
              child: Stack(children: [
                CachedNetworkImage(
                        imageUrl: widget.model.gallery.first.filePath)
                    .addPinchAndZoom(),
                model == null
                    ? Container()
                    : Positioned(
                        bottom: 40,
                        left: 15,
                        right: 15,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                        onTap: () => likeUnlikeApiCall(),
                                        child: ThemeIconWidget(
                                            model!.isLike
                                                ? ThemeIcon.filledStar
                                                : ThemeIcon.star,
                                            size: 25)),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    BodyLargeText(
                                        model!.totalLike > 1
                                            ? '${model!.totalLike} ${LocalizationString.likes}'
                                            : '${model!.totalLike} ${LocalizationString.like}',
                                        weight: TextWeight.medium)
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    InkWell(
                                        onTap: () => openComments(),
                                        child: const ThemeIconWidget(
                                            ThemeIcon.message)),
                                    InkWell(
                                      onTap: () => openComments(),
                                      child: model!.totalComment > 0
                                          ? Heading5Text(
                                              '${model!.totalComment} ${LocalizationString.comments}',
                                            )
                                          : Container(),
                                    )
                                  ])
                            ]),
                      )
              ]),
            ),
          ],
        ));
  }

  void openReportPostPopup() {
    if (!model!.isReported) {
      showModalBottomSheet(
          context: context,
          builder: (context) => Wrap(
                children: [
                  Heading3Text(LocalizationString.wantToReport,
                          weight: TextWeight.semiBold)
                      .p16,
                  ListTile(
                      leading: const ThemeIconWidget(ThemeIcon.camera),
                      title: Heading4Text(LocalizationString.report,
                          weight: TextWeight.regular),
                      onTap: () async {
                        Navigator.of(context).pop();
                        reportPostApiCall();
                      }),
                  divider(context: context),
                  ListTile(
                      leading: const ThemeIconWidget(ThemeIcon.close),
                      title: Heading4Text(LocalizationString.cancel,
                          weight: TextWeight.regular),
                      onTap: () => Navigator.of(context).pop()),
                ],
              ));
    }
  }

  void openComments() {
    Get.to(() => CommentsScreen(
        model: model!,
        commentPostedCallback: () {
          model!.totalComment += 1;
        },
        handler: () {
          if (widget.handler != null) {
            widget.handler!();
          }

          setState(() {});
        }));
  }

  void likeUnlikeApiCall() {
    model!.isLike = !model!.isLike;
    model!.totalLike =
        model!.isLike ? (model!.totalLike) + 1 : (model!.totalLike) - 1;

    if (widget.handler != null) {
      widget.handler!();
    }

    setState(() {});

    AppUtil.checkInternet().then((value) async {
      if (value) {
        ApiController()
            .likeUnlike(!model!.isLike, model!.id)
            .then((response) async {});
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet,
            isSuccess: false);
      }
    });
  }

  void reportPostApiCall() {
    model!.isReported = true;
    if (widget.handler != null) {
      widget.handler!();
    }

    setState(() {});
    AppUtil.checkInternet().then((value) async {
      if (value) {
        EasyLoading.show(status: LocalizationString.loading);
        ApiController().reportPost(model!.id).then((response) async {
          EasyLoading.dismiss();
        });
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet,
            isSuccess: false);
      }
    });
  }
}
