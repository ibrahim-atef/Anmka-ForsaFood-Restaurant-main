import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/controller/add_menu_controller.dart';
import 'package:restaurant/models/menu_model.dart';
import 'package:restaurant/models/product_model.dart';
import 'package:restaurant/models/vendor_category_model.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/responsive.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/themes/text_field_widget.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:restaurant/utils/network_image_widget.dart';
import 'package:dotted_border/dotted_border.dart';

class AddMenuScreen extends StatefulWidget {
  const AddMenuScreen({super.key});

  @override
  State<AddMenuScreen> createState() => _AddMenuScreenState();
}

class _AddMenuScreenState extends State<AddMenuScreen> {
  final AddMenuController controller = Get.put(AddMenuController());
  late ProductModel? editModel;
  // late MenuModel? editModel;
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    editModel = Get.arguments?['productModel'];
    // 👇 أضف السطرين التاليين
  selectedCategoryId = editModel!.categoryID;          // أو editModel!.categoryId على حسب اسم الحقل
  controller.selectedCategoryId.value = selectedCategoryId ?? '';
    print("Edit Model: $editModel");
    if (editModel != null) {
      controller.productDiscountPriceController.value.text = editModel!.disPrice ?? "";
controller.quantity.value = (editModel!.quantity == -1) ? 0 : (editModel!.quantity ?? 0);

      controller.menuModels.value = editModel!;
      controller.productNameController.value.text = editModel!.name ?? "";
      // controller.productNameController.value.text = editModel!.productName ?? "";
      controller.productDescription.value.text = editModel!.description ?? "";
      // controller.productDescription.value.text = editModel!.productDescription ?? "";
      controller.productPriceController.value.text = editModel!.price ?? "";
      // controller.productPriceController.value.text = editModel!.productPrice ?? "";
      if (editModel!.photo != null && editModel!.photo!.isNotEmpty) {
      // if (editModel!.productPhoto != null && editModel!.productPhoto!.isNotEmpty) {
        controller.images.clear();
        controller.images.add(editModel!.photo!);
        // controller.images.add(editModel!.productPhoto!);
      }
    }
  }


// final discountText = controller.productDiscountPriceController.value.text;
// final discount = int.tryParse(discountText);
// if (discount == null || discount < 0 || discount > 100) {
//   showError('Please enter a valid discount percentage between 0 and 100.');
//   return;
// }



  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
  // ✅ اضبط الافتراضي هنا
  if (selectedCategoryId == null &&
      controller.vendorCategoryModel.isNotEmpty) {
    selectedCategoryId = controller.vendorCategoryModel.first.id;
    controller.selectedCategoryId.value = selectedCategoryId!;
  }
    return GetX<AddMenuController>(
      init: AddMenuController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppThemeData.secondary300,
            title: Text(
              "Menu Details".tr,
              style: TextStyle(
                color: themeChange.getThem()
                    ? AppThemeData.grey900
                    : AppThemeData.grey50,
                fontSize: 18,
                fontFamily: AppThemeData.medium,
              ),
            ),
            iconTheme: const IconThemeData(color: AppThemeData.grey50),
          ),
          body: controller.isLoading.value
              ? Constant.loader()
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _buildImagePicker(themeChange),
                        const SizedBox(height: 12),
                        // _buildImagePreview(),
                        // const SizedBox(height: 12),
                        // _buildCategorySelector(themeChange),
                        // const SizedBox(height: 12),
                        // _buildNameDropdown(),
                        const SizedBox(height: 12),
                        // TextFieldWidget(
                        //   title: 'Product Description'.tr,
                        //   controller: controller.productDescription.value,
                        //   maxLine: 5,
                        //   hintText: 'Enter Product description here....'.tr,
                        //   enable: true,
                        // ),
                        // const SizedBox(height: 12),

_buildQuantitySelector(themeChange),
                        const SizedBox(height: 12),

TextFieldWidget(
  title: 'special offer (%)'.tr,
  controller: controller.productDiscountPriceController.value,
  hintText: 'Enter discount percentage (max 50%)'.tr,
  enable: true,
  textInputAction: TextInputAction.next,
  textInputType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(2),        // أقصى رقمين
  ],
  onchange: (value) {
    final intVal = int.tryParse(value);
    if (intVal != null && intVal > 50) {        // حد أقصى 50
      controller.productDiscountPriceController.value.text = '50';
      controller.productDiscountPriceController.value.selection =
          TextSelection.fromPosition(
        TextPosition(
          offset: controller.productDiscountPriceController.value.text.length,
        ),
      );
    }
  },
),

const SizedBox(height: 12),

                       TextFieldWidget(
                          enable: false,
                          title: 'Product price'.tr,
                          controller: controller.productPriceController.value,
                          hintText: 'Product price'.tr,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: RoundedButtonFill(
              title: "Save Details".tr,
              height: 5.5,
              color: AppThemeData.secondary300,
              textColor: AppThemeData.grey50,
              fontSizes: 16,
              onPress: () async {
                controller.saveDetails();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePicker(DarkThemeProvider themeChange) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      dashPattern: const [6, 6],
      color:
          themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
      child: Container(
        decoration: BoxDecoration(
          color: themeChange.getThem()
              ? AppThemeData.grey900
              : AppThemeData.grey50,
          borderRadius: BorderRadius.circular(12),
        ),
        width: double.infinity,
        height: Responsive.height(30, context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/ic_folder.svg'),
            const SizedBox(height: 10),
            Text(
              "Choose a image and upload here".tr,
              style: TextStyle(
                color: themeChange.getThem()
                    ? AppThemeData.grey100
                    : AppThemeData.grey800,
                fontFamily: AppThemeData.medium,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text("JPEG, PNG".tr, style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            RoundedButtonFill(
              title: "Browse Image".tr,
              color: AppThemeData.secondary50,
              width: 30,
              height: 5,
              textColor: AppThemeData.secondary300,
              onPress: () => _buildBottomSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return controller.images.isEmpty
        ? const SizedBox()
        : SizedBox(
            height: 200,
            
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.images.length,
              itemBuilder: (context, index) {
                final image = controller.images[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: image is XFile
                            ? Image.file(File(image.path),
                                fit: BoxFit.cover, width: 200, height: 200)
                            : NetworkImageWidget(
                                imageUrl: image,
                                fit: BoxFit.cover,
                                width: 200,
                                height: 200),
                      ),
                      // Positioned(
                      //   top: 0,
                      //   right: 0,
                      //   child: InkWell(
                      //     onTap: () =>
                      //         setState(() => controller.images.removeAt(index)),
                      //     child: const Icon(Icons.remove_circle,
                      //         size: 24, color: AppThemeData.danger300),
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
            ),
          );
  }

  Widget _buildCategorySelector(DarkThemeProvider themeChange) {
  return SizedBox(
    height: 120,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: controller.vendorCategoryModel.length,
      itemBuilder: (context, index) {
        final category = controller.vendorCategoryModel[index];
        final isSelected = category.id == selectedCategoryId;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategoryId = category.id;
              controller.selectedCategoryId.value = category.id ?? '';
              print("Selected Category ID: ${controller.selectedCategoryId.value}");
            });
          },
          child: Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (themeChange.getThem()
                      ? AppThemeData.primary600.withOpacity(0.2)
                      : AppThemeData.primary50)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppThemeData.primary400 : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: NetworkImageWidget(
                      imageUrl: category.photo ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category.title?.tr ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppThemeData.medium,
                    color: isSelected
                        ? AppThemeData.primary400
                        : (themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}


  Widget _buildNameDropdown() {
    return DropdownButtonFormField<String>(
      value: controller.selectedOption.value.isEmpty
          ? null
          : controller.selectedOption.value,
      items: [
        DropdownMenuItem(value: "Surprise bag", child: Text("Surprise bag")),
        DropdownMenuItem(value: "Mystery box", child: Text("Mystery box")),
      ],
      onChanged: (value) => controller.selectedOption.value = value!,
      decoration: const InputDecoration(
        labelText: "Select Product name",
        border: OutlineInputBorder(),
      ),
    );
  }

  void _buildBottomSheet(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: Responsive.height(25, context),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Text(
              "Please Select".tr,
              style: TextStyle(
                fontSize: 16,
                fontFamily: AppThemeData.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButton(Icons.camera_alt, "Camera",
                    () => controller.pickFile(source: ImageSource.camera)),
                _buildIconButton(Icons.photo_library, "Gallery",
                    () => controller.pickFile(source: ImageSource.gallery)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(onPressed: onPressed, icon: Icon(icon, size: 32)),
        Text(label.tr),
      ],
    );
  }


Widget _buildQuantitySelector(DarkThemeProvider themeChange) {
  return Obx(() {
    return Container(
      decoration: BoxDecoration(
        color: themeChange.getThem()
            ? AppThemeData.grey900
            : AppThemeData.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeChange.getThem()
              ? AppThemeData.grey700
              : AppThemeData.grey200,
          width: 1.5,
        ),
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Select Quantity".tr,
            style: TextStyle(
              color: themeChange.getThem()
                  ? AppThemeData.grey100
                  : AppThemeData.grey800,
              fontFamily: AppThemeData.medium,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 28),
                onPressed: controller.quantity.value > 0
                    ? () => controller.quantity.value--
                    : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: themeChange.getThem()
                      ? AppThemeData.grey800
                      : AppThemeData.grey200,
                ),
                child: Text(
                  controller.quantity.value.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 28),
                onPressed: () => controller.quantity.value++,
              ),
            ],
          ),
        ],
      ),
    );
  });
}



}
