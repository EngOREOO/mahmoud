import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:foap/apiHandler/apis/misc_api.dart';
import 'package:foap/apiHandler/apis/post_api.dart';
import 'package:foap/components/custom_gallery_picker.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:video_compress_ds/video_compress_ds.dart';
import 'package:path_provider/path_provider.dart';

import '../../apiHandler/apis/users_api.dart';
import '../../model/hash_tag.dart';
import '../../screens/chat/media.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../home/home_controller.dart';

class AddPostController extends GetxController {
  final HomeController _homeController = Get.find();

  RxInt isEditing = 0.obs;
  RxString currentHashtag = ''.obs;
  RxString currentUserTag = ''.obs;
  RxInt currentIndex = 0.obs;

  RxBool isPosting = false.obs;
  RxBool isErrorInPosting = false.obs;

  List<Media> postingMedia = [];
  late String postingTitle;

  RxList<Hashtag> hashTags = <Hashtag>[].obs;
  RxList<UserModel> searchedUsers = <UserModel>[].obs;

  int currentUpdateAbleStartOffset = 0;
  int currentUpdateAbleEndOffset = 0;

  RxString searchText = ''.obs;
  RxInt position = 0.obs;

  RxBool isPreviewMode = false.obs;

  int hashtagsPage = 1;
  bool canLoadMoreHashtags = true;
  bool hashtagsIsLoading = false;

  int accountsPage = 1;
  bool canLoadMoreAccounts = true;
  bool accountsIsLoading = false;
  RxBool enableComments = true.obs;

  clear() {
    searchText.value = '';
    hashtagsPage = 1;
    canLoadMoreHashtags = true;
    hashtagsIsLoading = false;

    accountsPage = 1;
    canLoadMoreAccounts = true;
    accountsIsLoading = false;
    enableComments.value = true;
    update();
  }

  updateGallerySlider(int index) {
    currentIndex.value = index;
    update();
  }

  togglePreviewMode() {
    isPreviewMode.value = !isPreviewMode.value;
    update();
  }

  toggleEnableComments() {
    enableComments.value = !enableComments.value;
    update();
  }

  startedEditing() {
    isEditing.value = 1;
    update();
  }

  stoppedEditing() {
    isEditing.value = 0;
    update();
  }

  searchHashTags({required String text, VoidCallback? callBackHandler}) {
    if (canLoadMoreHashtags) {
      hashtagsIsLoading = true;

      MiscApi.searchHashtag(
          page: hashtagsPage,
          hashtag: text.replaceAll('#', ''),
          resultCallback: (result, metaData) {
            hashTags.addAll(result);
            canLoadMoreHashtags = result.length >= metaData.perPage;
            hashtagsIsLoading = false;
            hashtagsPage += 1;

            update();
            if (callBackHandler != null) {
              callBackHandler();
            }
          });
    } else {
      if (callBackHandler != null) {
        callBackHandler();
      }
    }
  }

  addUserTag(String user) {
    String updatedText = searchText.value.replaceRange(
        currentUpdateAbleStartOffset, currentUpdateAbleEndOffset, '$user ');
    searchText.value = updatedText;
    position.value = updatedText.indexOf(user, currentUpdateAbleStartOffset) +
        user.length +
        1;

    currentUserTag.value = '';

    update();
  }

  addHashTag(String hashtag) {
    String updatedText = searchText.value.replaceRange(
        currentUpdateAbleStartOffset, currentUpdateAbleEndOffset, '$hashtag ');
    position.value =
        updatedText.indexOf(hashtag, currentUpdateAbleStartOffset) +
            hashtag.length +
            1;

    searchText.value = updatedText;
    currentHashtag.value = '';

    update();
  }

  searchUsers({required String text, VoidCallback? callBackHandler}) {
    if (canLoadMoreAccounts) {
      accountsIsLoading = true;

      UsersApi.searchUsers(
          page: accountsPage,
          isExactMatch: 0,
          searchText: text.replaceAll('@', ''),
          resultCallback: (result, metadata) {
            searchedUsers.addAll(result);
            accountsIsLoading = false;
            canLoadMoreAccounts = result.length >= metadata.perPage;
            accountsPage += 1;
            update();

            if (callBackHandler != null) {
              callBackHandler();
            }
          });
    } else {
      if (callBackHandler != null) {
        callBackHandler();
      }
    }
  }

  textChanged(String text, int position) {
    clear();
    isEditing.value = 1;
    searchText.value = text;
    String substring = text.substring(0, position).replaceAll("\n", " ");
    List<String> parts = substring.split(' ');
    String lastPart = parts.last;

    if (lastPart.startsWith('#') == true && lastPart.contains('@') == false) {
      if (currentHashtag.value.startsWith('#') == false) {
        currentHashtag.value = lastPart;
        currentUpdateAbleStartOffset = position;
      }

      if (lastPart.length > 1) {
        searchHashTags(text: lastPart);
        currentUpdateAbleEndOffset = position;
      }
    } else if (lastPart.startsWith('@') == true &&
        lastPart.contains('#') == false) {
      if (currentUserTag.value.startsWith('@') == false) {
        currentUserTag.value = lastPart;
        currentUpdateAbleStartOffset = position;
      }
      if (lastPart.length > 1) {
        searchUsers(text: lastPart);
        currentUpdateAbleEndOffset = position;
      }
    } else {
      if (currentHashtag.value.startsWith('#') == true) {
        currentHashtag.value = lastPart;
      }
      currentHashtag.value = '';
      hashTags.value = [];

      if (currentUserTag.value.startsWith('!') == true) {
        currentUserTag.value = lastPart;
      }
      currentUserTag.value = '';
      searchedUsers.value = [];
    }

    this.position.value = position;
  }

  discardFailedPost() {
    postingMedia = [];
    postingTitle = '';
    isPosting.value = false;
    isErrorInPosting.value = false;
    clear();
  }

  retryPublish() {
    uploadAllPostFiles(
        items: postingMedia, title: postingTitle, allowComments: true);
  }

  void uploadAllPostFiles(
      {required List<Media> items,
      required String title,
      required bool allowComments,
      int? competitionId,
      int? clubId,
      bool isReel = false,
      int? audioId,
      double? audioStartTime,
      double? audioEndTime}) async {
    postingMedia = items;
    postingTitle = title;
    isPosting.value = true;

    if (competitionId == null && clubId == null) {
      Get.offAll(() => const DashboardScreen());
    } else {
      EasyLoading.show(status: loadingString.tr);
    }

    var responses = await Future.wait([
      for (Media media in items)
        uploadMedia(
          media,
          competitionId,
        )
    ]).whenComplete(() {});

    publishAction(
      galleryItems: responses,
      title: title,
      allowComments: allowComments,
      tags: title.getHashtags(),
      mentions: title.getMentions(),
      competitionId: competitionId,
      clubId: clubId,
      isReel: isReel,
      audioId: audioId,
      audioStartTime: audioStartTime,
      audioEndTime: audioEndTime,
    );
  }

  Future<Map<String, String>> uploadMedia(
      Media media, int? competitionId) async {
    Map<String, String> gallery = {};
    final completer = Completer<Map<String, String>>();

    final tempDir = await getTemporaryDirectory();
    File file;
    String? videoThumbnailPath;

    if (media.mediaType == GalleryMediaType.photo) {
      Uint8List mainFileData = await media.file!.compress();

      //image media
      file = await File('${tempDir.path}/${media.id!.replaceAll('/', '')}.png')
          .create();
      file.writeAsBytesSync(mainFileData);
    } else {
      MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        media.file!.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false, // It's false by default
      );

      // code after compressing
      file = mediaInfo!.file!;

      File videoThumbnail = await File(
              '${tempDir.path}/${media.id!.replaceAll('/', '')}_thumbnail.png')
          .create();

      videoThumbnail.writeAsBytesSync(media.thumbnail!);

      await PostApi.uploadFile(videoThumbnail.path,
          resultCallback: (fileName, filePath) async {
        videoThumbnailPath = fileName;
        await videoThumbnail.delete();
      });
    }

    // EasyLoading.show(status: loadingString.tr);
    await PostApi.uploadFile(file.path,
        resultCallback: (fileName, filePath) async {
      String imagePath = fileName;

      await file.delete();

      gallery = {
        'filename': imagePath,
        'video_thumb': videoThumbnailPath ?? '',
        'type': competitionId == null ? '1' : '2',
        'media_type': media.mediaType == GalleryMediaType.photo ? '1' : '2',
        'is_default': '1',
      };
      completer.complete(gallery);
    });

    return completer.future;
  }

  void publishAction({
    required List<Map<String, String>> galleryItems,
    required String title,
    required List<String> tags,
    required List<String> mentions,
    required bool allowComments,
    int? competitionId,
    int? clubId,
    bool isReel = false,
    int? audioId,
    double? audioStartTime,
    double? audioEndTime,
  }) {
    PostApi.addPost(
        postType: isReel == true
            ? PostType.reel
            : competitionId != null
                ? PostType.competition
                : clubId != null
                    ? PostType.club
                    : PostType.basic,
        allowComments: allowComments,
        title: title,
        gallery: galleryItems,
        hashTag: tags.join(','),
        mentions: mentions.join(','),
        competitionId: competitionId,
        clubId: clubId,
        audioId: audioId,
        audioStartTime: audioStartTime,
        audioEndTime: audioEndTime,
        resultCallback: (postId) {
          if (postId != null) {
            if (competitionId != null || clubId != null) {
              EasyLoading.dismiss();
              Get.offAll(() => const DashboardScreen());
            }

            postingMedia = [];
            postingTitle = '';

            PostApi.getPostDetail(postId, resultCallback: (result) {
              if (result != null) {
                _homeController.addNewPost(result);
              }
              isPosting.value = false;
            });

            clear();
          } else {
            isErrorInPosting.value = true;
          }
        });
  }

  void updatePost({
    required int postId,
    required String title,
    required bool allowComments,
  }) {
    PostApi.updatePost(
      postId: postId,
      title: title,
      allowComments: allowComments,
    );
    Get.back();
  }
}
