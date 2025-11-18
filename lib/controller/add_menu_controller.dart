import 'dart:io';
import 'package:restaurant/models/vendor_category_model.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/models/menu_model.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/models/vendor_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

import '../models/product_model.dart';

class AddMenuController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<VendorCategoryModel> vendorCategoryModel = <VendorCategoryModel>[].obs;

  Rx<TextEditingController> productNameController = TextEditingController().obs;
  Rx<TextEditingController> productDescription = TextEditingController().obs;
  Rx<TextEditingController> productPriceController =
      TextEditingController().obs;
  RxString selectedCategoryId = ''.obs;

  RxList images = <dynamic>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getMenu();
    getVendorCategory();
    super.onInit();
  }

  getVendorCategory() async {
    await FireStoreUtils.getHomeVendorCategory().then(
      (value) {
        vendorCategoryModel.value = value;
      },
    );
  }

  Rx<UserModel> userModel = UserModel().obs;
  RxList<ProductModel> menuModel = <ProductModel>[].obs;
  Rx<TextEditingController> productDiscountPriceController = TextEditingController().obs;

  // RxList<MenuModel> menuModel = <MenuModel>[].obs;
  Rx<ProductModel> menuModels = ProductModel().obs;
  // Rx<MenuModel> menuModels = MenuModel().obs;
  Rx<DeliveryCharge> deliveryChargeModel = DeliveryCharge().obs;
  var selectedOption = "Surprise bag".obs;
  RxInt quantity = 1.obs;


  getMenu() async {
    isLoading.value = true;
    print("getMenu1");
    try {
      List<ProductModel> model = await FireStoreUtils.getMenuForUser();
      // List<MenuModel> model = await FireStoreUtils.getMenuForUser();
          print("getMenu2");

      print("model $model");
      menuModel.value = model;
    } catch (e) {
      print("Error fetching menu: $e");
    }
    isLoading.value = false;
  }

saveDetails() async {
  print("🚀 Starting saveDetails");

  if (selectedOption.value.isEmpty) {
    ShowToastDialog.showToast("Please select product name");
    print("⚠️ Validation failed: selectedOption is empty");
    return;
  }

  if (productPriceController.value.text.isEmpty) {
    ShowToastDialog.showToast("Please enter product price");
    print("⚠️ Validation failed: price is empty");
    return;
  }
menuModels.value.quantity = quantity.value;
menuModels.value.disPrice = productDiscountPriceController.value.text;

  ShowToastDialog.showLoader("Saving Menu Details");

  // 🔄 Upload images if needed
  for (int i = 0; i < images.length; i++) {
    if (images[i] is XFile) {
      try {
        print("📸 Uploading image $i: ${images[i].path}");
        String url = await Constant.uploadUserImageToFireStorage(
          File(images[i].path),
          "profileImage/${FireStoreUtils.getCurrentUid()}",
          File(images[i].path).path.split('/').last,
        );
        print("✅ Image uploaded: $url");
        images[i] = url;
      } catch (e) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Image upload failed: $e");
        print("❌ Image upload failed: $e");
        return;
      }
    }
  }

  // 📄 Assign data to model
  print("🧾 Assigning data to menuModels");

  menuModels.value.vendorID = Constant.userModel!.vendorID;
  menuModels.value.categoryID = selectedCategoryId.value;
  menuModels.value.photo = images.isNotEmpty ? images.first : "";
  menuModels.value.name = selectedOption.value;
  menuModels.value.description = productDescription.value.text;
  menuModels.value.price = productPriceController.value.text;

  print("📋 menuModels data:");
  print("vendorID: ${menuModels.value.vendorID}");
  print("categoryID: ${menuModels.value.categoryID}");
  print("photo: ${menuModels.value.photo}");
  print("name: ${menuModels.value.name}");
  print("description: ${menuModels.value.description}");
  print("price: ${menuModels.value.price}");

  try {
    bool isUpdating = menuModels.value.id != null &&
        menuModels.value.id!.isNotEmpty;

    print("🔄 Operation: ${isUpdating ? 'Update' : 'Create'}");

    if (isUpdating) {
      // ✅ Update menu
      bool success = await FireStoreUtils.updateMenu(menuModels.value);
      ShowToastDialog.closeLoader();

      if (success) {
        ShowToastDialog.showToast("Menu updated successfully");
        print("✅ Menu updated successfully");
        Get.back(result: true);
      } else {
        ShowToastDialog.showToast("Failed to update menu");
        print("❌ Failed to update menu");
      }
    } else {
      // ✅ Create new menu
      final result = await FireStoreUtils.firebaseCreateNewMenu(menuModels.value);
      ShowToastDialog.closeLoader();

      if (result != null) {
        ShowToastDialog.showToast("Menu created successfully");
        print("✅ Menu created successfully: ${result}");

        selectedOption.value = "";
        productDescription.value.clear();
        productPriceController.value.clear();
        images.clear();

        Get.back(result: true);
      } else {
        ShowToastDialog.showToast("Failed to create menu");
        print("❌ Failed to create menu");
      }
    }
  } catch (e, stackTrace) {
    ShowToastDialog.closeLoader();
    ShowToastDialog.showToast("Error saving menu: $e");
    print("❌ Exception occurred while saving: $e");
    print("📍 Stack trace:\n$stackTrace");
  }
}


  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      images.add(image);
      Get.back();
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("Failed to Pick : \n $e");
    }
  }
}
