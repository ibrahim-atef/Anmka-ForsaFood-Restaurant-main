import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  RxInt quantity = (-1).obs; // Default -1 means unlimited stock


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

  // Validate product name - use productNameController instead of selectedOption
  String productName = productNameController.value.text.trim();
  if (productName.isEmpty) {
    ShowToastDialog.showToast("Please enter product name");
    print("⚠️ Validation failed: product name is empty");
    return;
  }

  if (productPriceController.value.text.isEmpty) {
    ShowToastDialog.showToast("Please enter product price");
    print("⚠️ Validation failed: price is empty");
    return;
  }

  // Validate discount price if provided - must be less than product price
  String discountPriceText = productDiscountPriceController.value.text.trim();
  if (discountPriceText.isNotEmpty) {
    double? discountPrice = double.tryParse(discountPriceText);
    double? productPrice = double.tryParse(productPriceController.value.text.trim());
    
    if (discountPrice == null) {
      ShowToastDialog.showToast("Please enter a valid discount price");
      print("⚠️ Validation failed: discount price is not a valid number");
      return;
    }
    
    if (productPrice == null) {
      ShowToastDialog.showToast("Please enter a valid product price");
      print("⚠️ Validation failed: product price is not a valid number");
      return;
    }
    
    if (discountPrice >= productPrice) {
      ShowToastDialog.showToast("Discount price must be less than product price");
      print("⚠️ Validation failed: discount price ($discountPrice) is not less than product price ($productPrice)");
      return;
    }
    
    if (discountPrice < 0) {
      ShowToastDialog.showToast("Discount price cannot be negative");
      print("⚠️ Validation failed: discount price is negative");
      return;
    }
  }

  // Check if editing existing product
  bool isEditing = menuModels.value.id != null && menuModels.value.id!.isNotEmpty;
  print("📝 [AddMenuController] Is editing existing product: $isEditing, Product ID: ${menuModels.value.id}");
  
  // Store original createdAt if editing
  Timestamp? originalCreatedAt = menuModels.value.createdAt;

  // ✅ FIX: Preserve quantity - if it's -1 (unlimited), keep it as -1
  // Don't allow saving 0 if original was -1 unless explicitly set by user
  menuModels.value.quantity = quantity.value;
  menuModels.value.disPrice = productDiscountPriceController.value.text;
  
  print("📦 [AddMenuController] Saving quantity: ${menuModels.value.quantity} (original was: ${originalCreatedAt != null ? 'editing' : 'new'})");

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
  
  // ✅ FIX: Use productNameController instead of selectedOption to preserve user input
  menuModels.value.name = productName;
  print("✅ [AddMenuController] Using product name from controller: $productName");
  
  menuModels.value.description = productDescription.value.text;
  menuModels.value.price = productPriceController.value.text;
  
  // Preserve original createdAt if editing, otherwise set new timestamp
  if (isEditing && originalCreatedAt != null) {
    menuModels.value.createdAt = originalCreatedAt;
    print("✅ [AddMenuController] Preserved original createdAt: $originalCreatedAt");
  } else if (!isEditing) {
    menuModels.value.createdAt = Timestamp.now();
    print("✅ [AddMenuController] Set new createdAt: ${menuModels.value.createdAt}");
  }

  print("📋 menuModels data:");
  print("vendorID: ${menuModels.value.vendorID}");
  print("categoryID: ${menuModels.value.categoryID}");
  print("photo: ${menuModels.value.photo}");
  print("name: ${menuModels.value.name}");
  print("description: ${menuModels.value.description}");
  print("price: ${menuModels.value.price}");
  print("createdAt: ${menuModels.value.createdAt}");

  try {
    // isUpdating already checked above
    print("🔄 Operation: ${isEditing ? 'Update' : 'Create'}");

    if (isEditing) {
      // ✅ Update menu
      print("💾 [AddMenuController] Calling updateMenu()...");
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
