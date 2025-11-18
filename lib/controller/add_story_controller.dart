import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant/constant/collection_name.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/models/story_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class AddStoryController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<StoryModel> storyModel = StoryModel().obs;

  final ImagePicker imagePicker = ImagePicker();
  RxList<dynamic> mediaFiles = <dynamic>[].obs;
  RxList<dynamic> thumbnailFile = <dynamic>[].obs;

  RxDouble videoDuration = 0.0.obs;

  RxInt storyCount = 0.obs;
  RxBool canUploadStory = true.obs;

  @override
  void onInit() {
    getStory();
    super.onInit();
  }

  Future<void> getStory() async {
    isLoading.value = true;

    final snap = await FireStoreUtils.fireStore
        .collection(CollectionName.story)
        .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
        .get();

    if (snap.docs.isNotEmpty) {
      final data = snap.docs.first.data();
      storyCount.value = (data['videoUrl'] ?? []).length;
      canUploadStory.value = storyCount.value < 10;

      storyModel.value = StoryModel.fromJson(data);
      thumbnailFile
        ..clear()
        ..add(storyModel.value.videoThumbnail);

      mediaFiles
        ..clear()
        ..addAll(storyModel.value.videoUrl);
    } else {
      storyCount.value = 0;
      canUploadStory.value = true;
    }

    final settings = await FireStoreUtils.fireStore
        .collection(CollectionName.settings)
        .doc('story')
        .get();
    videoDuration.value = double.parse(settings['videoDuration'].toString());

    isLoading.value = false;
  }

  Future<void> refreshStoryCount() async => await getStory();
}
