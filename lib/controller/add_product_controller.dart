import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant/constant/collection_name.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/models/AttributesModel.dart';
import 'package:restaurant/models/product_model.dart';
import 'package:restaurant/models/vendor_category_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class AddProductController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<TextEditingController> attributesValueController = TextEditingController().obs;

  Rx<TextEditingController> productTitleController = TextEditingController().obs;
  Rx<TextEditingController> productDescriptionController = TextEditingController().obs;
  Rx<TextEditingController> regularPriceController = TextEditingController().obs;
  Rx<TextEditingController> discountedPriceController = TextEditingController().obs;
  Rx<TextEditingController> productQuantityController = TextEditingController().obs;
  Rx<TextEditingController> caloriesController = TextEditingController().obs;
  Rx<TextEditingController> gramsController = TextEditingController().obs;
  Rx<TextEditingController> proteinController = TextEditingController().obs;
  Rx<TextEditingController> fatsController = TextEditingController().obs;

  Rx<ItemAttribute?> itemAttributes = ItemAttribute(attributes: [], variants: []).obs;

  RxList<VendorCategoryModel> vendorCategoryList = <VendorCategoryModel>[].obs;
  Rx<VendorCategoryModel> selectedProductCategory = VendorCategoryModel().obs;

  final myKey1 = GlobalKey<DropdownSearchState<AttributesModel>>();

  Rx<ProductModel> productModel = ProductModel().obs;
  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList images = <dynamic>[].obs;

  RxList<AttributesModel> attributesList = <AttributesModel>[].obs;
  RxList<AttributesModel> selectedAttributesList = <AttributesModel>[].obs;

  RxList<ProductSpecificationModel> specificationList = <ProductSpecificationModel>[].obs;
  RxList<ProductSpecificationModel> addonsList = <ProductSpecificationModel>[].obs;

  RxString title = "".obs;

  RxBool isPublish = true.obs;
  RxBool isPureVeg = true.obs;
  RxBool isNonVeg = false.obs;

  RxBool takeAway = false.obs;
  RxBool isDiscountedPriceOk = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  addAttribute(String id) {
    ItemAttribute? itemAttribute = itemAttributes.value;
    List<Attributes>? attributesList = itemAttribute!.attributes;
    attributesList!.add(Attributes(attributeId: id, attributeOptions: []));
    itemAttributes.value = itemAttribute;
    update();
  }

  getArgument() async {
    log("🔵 [AddProductController] getArgument() - Starting...");
    
    await FireStoreUtils.getVendorCategoryById().then((value) {
      if (value != null) {
        vendorCategoryList.value = value;
        log("✅ [AddProductController] Loaded ${value.length} vendor categories");
      }
    });

    await FireStoreUtils.getAttributes().then((value) {
      if (value != null) {
        attributesList.value = value;
        log("✅ [AddProductController] Loaded ${value.length} attributes");
      }
    });

    await FireStoreUtils.fireStore
        .collection(CollectionName.vendorProducts)
        .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
        .where('createdAt', isGreaterThan: Constant.userModel?.subscriptionPlan?.createdAt)
        .get()
        .then((value) {
      for (var element in value.docs) {
        ProductModel productModel = ProductModel.fromJson(element.data());
        productList.add(productModel);
        log("📦 [AddProductController] ProductList :: ${productList.length}");
      }
    });

    dynamic argumentData = Get.arguments;
    if (argumentData != null && argumentData['productModel'] != null) {
      log("📥 [AddProductController] Editing existing product...");
      productModel.value = argumentData['productModel'];
      
      log("🔍 [AddProductController] Original Product Data:");
      log("   - ID: ${productModel.value.id}");
      log("   - Name: ${productModel.value.name}");
      log("   - Price: ${productModel.value.price}");
      log("   - DisPrice: ${productModel.value.disPrice}");
      log("   - CategoryID: ${productModel.value.categoryID}");
      log("   - VendorID: ${productModel.value.vendorID}");
      log("   - CreatedAt: ${productModel.value.createdAt}");
      log("   - Description: ${productModel.value.description}");
      log("   - Quantity: ${productModel.value.quantity}");

      for (var element in productModel.value.photos ?? []) {
        images.add(element);
      }
      log("📸 [AddProductController] Loaded ${images.length} images");

      isPublish.value = productModel.value.publish ?? false;
      productTitleController.value.text = productModel.value.name.toString();
      productDescriptionController.value.text = productModel.value.description.toString();
      regularPriceController.value.text = productModel.value.price.toString();
      discountedPriceController.value.text = productModel.value.disPrice.toString();
      productQuantityController.value.text = productModel.value.quantity.toString();

      caloriesController.value.text = productModel.value.calories.toString();
      gramsController.value.text = productModel.value.grams.toString();
      fatsController.value.text = productModel.value.fats.toString();
      proteinController.value.text = productModel.value.proteins.toString();
      isPureVeg.value = productModel.value.veg ?? true;
      isNonVeg.value = productModel.value.nonveg ?? false;
      takeAway.value = productModel.value.takeawayOption ?? false;
      
      if (productModel.value.productSpecification != null) {
        productModel.value.productSpecification!.forEach((key, value) {
          specificationList.add(ProductSpecificationModel(lable: key, value: value));
        });
      }

      itemAttributes.value = productModel.value.itemAttribute ?? ItemAttribute();

      if (productModel.value.itemAttribute != null && productModel.value.itemAttribute!.attributes != null) {
        for (var element in productModel.value.itemAttribute!.attributes!) {
          try {
            AttributesModel attributesModel = attributesList.firstWhere((product) => product.id == element.attributeId);
            selectedAttributesList.add(attributesModel);
          } catch (e) {
            log("⚠️ [AddProductController] Attribute not found: ${element.attributeId}");
          }
        }
      }

      if (productModel.value.addOnsTitle != null) {
        for (var element in productModel.value.addOnsTitle!) {
          int index = productModel.value.addOnsTitle!.indexOf(element);
          if (productModel.value.addOnsPrice != null && index < productModel.value.addOnsPrice!.length) {
            addonsList.add(ProductSpecificationModel(lable: element, value: productModel.value.addOnsPrice![index]));
          }
        }
      }

      for (var element in vendorCategoryList) {
        if (element.id == productModel.value.categoryID) {
          selectedProductCategory.value = element;
          log("✅ [AddProductController] Selected category: ${element.title ?? 'Unknown'}");
          break;
        }
      }
      
      log("✅ [AddProductController] Product data loaded into form successfully");
    } else {
      log("🆕 [AddProductController] Creating new product");
    }

    isLoading.value = false;
    log("✅ [AddProductController] getArgument() - Completed");
  }

  Map<String, dynamic> specification = {};

  saveDetails() async {
    log("💾 [AddProductController] saveDetails() - Starting save process...");
    
    // Validation checks
    if (selectedProductCategory.value.id == null) {
      log("❌ [AddProductController] Validation failed: Category not selected");
      ShowToastDialog.showToast("Please Select category");
      return;
    }
    
    if (productTitleController.value.text.trim().isEmpty) {
      log("❌ [AddProductController] Validation failed: Title is empty");
      ShowToastDialog.showToast("Please enter title");
      return;
    }
    
    if (productDescriptionController.value.text.isEmpty) {
      log("❌ [AddProductController] Validation failed: Description is empty");
      ShowToastDialog.showToast("Please enter description");
      return;
    }
    
    if (regularPriceController.value.text.isEmpty) {
      log("❌ [AddProductController] Validation failed: Regular price is empty");
      ShowToastDialog.showToast("Please enter valid regular price");
      return;
    }
    
    if (isDiscountedPriceOk.value == true) {
      log("❌ [AddProductController] Validation failed: Discount price is invalid");
      ShowToastDialog.showToast("Please enter valid discount price");
      return;
    }
    
    if (productQuantityController.value.text.isEmpty) {
      log("❌ [AddProductController] Validation failed: Quantity is empty");
      ShowToastDialog.showToast("Please enter product quantity");
      return;
    }
    
    double? regularPriceCheck = double.tryParse(regularPriceController.value.text.toString());
    if (regularPriceCheck == null || regularPriceCheck <= 0) {
      log("❌ [AddProductController] Validation failed: Regular price is invalid: ${regularPriceController.value.text}");
      ShowToastDialog.showToast("Please enter valid regular price");
      return;
    }

    log("✅ [AddProductController] All validations passed");
    
    // Store original createdAt if editing existing product
    Timestamp? originalCreatedAt = productModel.value.createdAt;
    bool isEditing = productModel.value.id != null && productModel.value.id!.isNotEmpty;
    log("📝 [AddProductController] Is editing existing product: $isEditing, Product ID: ${productModel.value.id}");
    
    specification.clear();
    for (var element in specificationList) {
      if (element.value != null && element.value!.isNotEmpty && element.lable != null && element.lable!.isNotEmpty) {
        specification.addEntries([MapEntry(element.lable.toString(), element.value)]);
      }
    }

    ShowToastDialog.showLoader("Please wait");
    
    log("📤 [AddProductController] Uploading images...");
    for (int i = 0; i < images.length; i++) {
      if (images[i].runtimeType == XFile) {
        log("   - Uploading image ${i + 1}/${images.length}");
        String url = await Constant.uploadUserImageToFireStorage(
          File(images[i].path),
          "profileImage/${FireStoreUtils.getCurrentUid()}",
          File(images[i].path).path.split('/').last,
        );
        images.removeAt(i);
        images.insert(i, url);
        log("   - Image uploaded: $url");
      }
    }

    List listAddTitle = [];
    List listAddPrice = [];
    for (var element in addonsList) {
      if (element.value != null && element.value!.isNotEmpty && element.lable != null && element.lable!.isNotEmpty) {
        listAddTitle.add(element.lable.toString());
        listAddPrice.add(element.value.toString());
      }
    }

    // Generate ID only for new products
    if (productModel.value.id == null || productModel.value.id!.isEmpty) {
      productModel.value.id = Constant.getUuid();
      log("🆕 [AddProductController] Generated new product ID: ${productModel.value.id}");
    } else {
      log("✏️ [AddProductController] Using existing product ID: ${productModel.value.id}");
    }
    
    productModel.value.photo = images.isNotEmpty ? images.first : "";
    productModel.value.photos = images;
    
    // Parse and validate prices
    String regularPriceText = regularPriceController.value.text.trim();
    String discountedPriceText = discountedPriceController.value.text.trim();
    
    double? regularPrice = double.tryParse(regularPriceText);
    if (regularPrice == null || regularPrice <= 0) {
      log("❌ [AddProductController] Invalid regular price: $regularPriceText");
      ShowToastDialog.showToast("Please enter valid regular price");
      ShowToastDialog.closeLoader();
      return;
    }
    
    double? discountedPrice = discountedPriceText.isEmpty ? null : double.tryParse(discountedPriceText);
    if (discountedPrice != null) {
      if (discountedPrice <= 0) {
        discountedPrice = null;
        log("⚠️ [AddProductController] Invalid discount price treated as no discount");
      } else if (discountedPrice >= regularPrice) {
        log("❌ [AddProductController] Discount price ($discountedPrice) >= Regular price ($regularPrice)");
        ShowToastDialog.showToast("Discounted price must be less than regular price");
        ShowToastDialog.closeLoader();
        return;
      }
    }
    
    // Update product model with form data
    productModel.value.price = regularPrice.toString();
    productModel.value.disPrice = (discountedPrice != null ? discountedPrice.toString() : "0");
    productModel.value.quantity = int.parse(productQuantityController.value.text);
    productModel.value.description = productDescriptionController.value.text;
    productModel.value.calories = int.parse(caloriesController.value.text.isEmpty ? "0" : caloriesController.value.text);
    productModel.value.grams = int.parse(gramsController.value.text.isEmpty ? "0" : gramsController.value.text);
    productModel.value.proteins = int.parse(proteinController.value.text.isEmpty ? "0" : proteinController.value.text);
    productModel.value.fats = int.parse(fatsController.value.text.isEmpty ? "0" : fatsController.value.text);
    
    String productName = productTitleController.value.text.trim();
    if (productName.isEmpty) {
      log("❌ [AddProductController] Product name is empty after trim");
      ShowToastDialog.showToast("Please enter valid product title");
      ShowToastDialog.closeLoader();
      return;
    }
    productModel.value.name = productName;
    productModel.value.veg = isPureVeg.value;
    productModel.value.nonveg = isNonVeg.value;
    productModel.value.publish = isPublish.value;
    productModel.value.vendorID = Constant.userModel!.vendorID;
    productModel.value.categoryID = selectedProductCategory.value.id.toString();
    productModel.value.itemAttribute = ((itemAttributes.value!.attributes == null || itemAttributes.value!.attributes!.isEmpty) &&
            (itemAttributes.value!.variants == null || itemAttributes.value!.variants!.isEmpty))
        ? null
        : itemAttributes.value;
    productModel.value.addOnsTitle = listAddTitle;
    productModel.value.addOnsPrice = listAddPrice;
    productModel.value.takeawayOption = takeAway.value;
    productModel.value.productSpecification = specification;
    
    // Preserve original createdAt if editing, otherwise set new timestamp
    if (isEditing && originalCreatedAt != null) {
      productModel.value.createdAt = originalCreatedAt;
      log("✅ [AddProductController] Preserved original createdAt: $originalCreatedAt");
    } else {
      productModel.value.createdAt = Timestamp.now();
      log("✅ [AddProductController] Set new createdAt: ${productModel.value.createdAt}");
    }
    
    log("📋 [AddProductController] Final Product Data to Save:");
    log("   - ID: ${productModel.value.id}");
    log("   - Name: ${productModel.value.name}");
    log("   - Price: ${productModel.value.price}");
    log("   - DisPrice: ${productModel.value.disPrice}");
    log("   - CategoryID: ${productModel.value.categoryID}");
    log("   - VendorID: ${productModel.value.vendorID}");
    log("   - CreatedAt: ${productModel.value.createdAt}");
    log("   - Description: ${productModel.value.description}");
    log("   - Quantity: ${productModel.value.quantity}");
    log("   - Publish: ${productModel.value.publish}");
    log("   - Veg: ${productModel.value.veg}, NonVeg: ${productModel.value.nonveg}");
    
    log("💾 [AddProductController] Calling updateProduct()...");
    bool success = await FireStoreUtils.updateProduct(productModel.value);
    
    if (success) {
      log("✅ [AddProductController] Product saved successfully!");
    } else {
      log("❌ [AddProductController] Failed to save product!");
    }
    
    ShowToastDialog.closeLoader();
    Get.back(result: true);
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      images.clear();
      images.add(image);
      Get.back();
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("Failed to Pick : \n $e");
    }
  }

  List<dynamic> getCombination(List<List<dynamic>> listArray) {
    if (listArray.length == 1) {
      return listArray[0];
    } else {
      List<dynamic> result = [];
      var allCasesOfRest = getCombination(listArray.sublist(1));
      for (var i = 0; i < allCasesOfRest.length; i++) {
        for (var j = 0; j < listArray[0].length; j++) {
          result.add(listArray[0][j] + "-" + allCasesOfRest[i]);
        }
      }
      return result;
    }
  }
}
