import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/app/add_menu_screen/add_menu_screen.dart';
import 'package:restaurant/app/add_restaurant_screen/add_restaurant_screen.dart';
import 'package:restaurant/app/product_screens/add_product_screen.dart';
import 'package:restaurant/app/verification_screen/verification_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/controller/add_menu_controller.dart';
import 'package:restaurant/controller/menu_list_controller.dart';
import 'package:restaurant/controller/product_list_controller.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/responsive.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/network_image_widget.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: MenuListController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppThemeData.primary300,
              centerTitle: false,
              title: Text(
                "Menu".tr,
                style: TextStyle(
                    color: themeChange.getThem()
                        ? AppThemeData.grey900
                        : AppThemeData.grey50,
                    fontSize: 18,
                    fontFamily: AppThemeData.medium),
              ),

              // actions: [
              //   InkWell(
              //     onTap: () {
              //       // if (controller.menuList.isEmpty ) {
              //       //   // ShowToastDialog.showToast(
              //       //   //     "Your current subscription plan has reached its maximum product limit. Upgrade now to add more products."
              //       //   //         .tr);
              //       // } else {
              //       Get.to(const AddMenuScreen())!.then(
              //         (value) {
              //           if (value == true) {
              //             controller.getMenu();
              //           }
              //         },
              //       );
              //       // }
              //     },
              //     child: Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 16),
              //       child: Row(
              //         children: [
              //           Icon(
              //             Icons.add,
              //             color: themeChange.getThem()
              //                 ? AppThemeData.grey50
              //                 : AppThemeData.grey50,
              //           ),
              //           const SizedBox(
              //             width: 5,
              //           ),
              //           Text(
              //             "Add".tr,
              //             style: TextStyle(
              //                 color: themeChange.getThem()
              //                     ? AppThemeData.grey50
              //                     : AppThemeData.grey50,
              //                 fontSize: 18,
              //                 fontFamily: AppThemeData.medium),
              //           )
              //         ],
              //       ),
              //     ),
              //   )
              // ],
            
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: RefreshIndicator(
                  onRefresh: () async {
                    await controller.getMenu();
                  },
                  child: controller.menuList.isEmpty
                      ? RefreshIndicator(
                          onRefresh: () async {
                            await controller.getMenu();
                          },
                          child: Center(
                            child: Text(
                              "No products found",
                              style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey900,
                                fontSize: 16,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: controller.menuList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            String price = "0.0";
                            String disPrice = "0.0";

                            price = controller.menuList[index].price
                            // price = controller.menuList[index].productPrice
                                .toString();

                            return InkWell(
                              onTap: () {
                                Get.to(const AddMenuScreen(), arguments: {
                                  "productModel": controller.menuList[index]
                                })!
                                    .then(
                                  (value) {
                                    if (value == true) {
                                      controller.getMenu();
                                    }
                                  },
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Container(
                                  decoration: ShapeDecoration(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey900
                                        : AppThemeData.grey50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(16)),
                                              child: Stack(
                                                children: [
                                                  NetworkImageWidget(
                                                    imageUrl: controller
                                                        .menuList[index]
                                                        .photo
                                                        // .productPhoto
                                                        .toString(),
                                                    fit: BoxFit.cover,
                                                    height: Responsive.height(
                                                        12, context),
                                                    width: Responsive.width(
                                                        24, context),
                                                  ),
                                                  Container(
                                                    height: Responsive.height(
                                                        12, context),
                                                    width: Responsive.width(
                                                        24, context),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: const Alignment(
                                                            -0.00, -1.00),
                                                        end: const Alignment(
                                                            0, 1),
                                                        colors: [
                                                          Colors.black
                                                              .withOpacity(0),
                                                          const Color(
                                                              0xFF111827)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        controller.menuList[index]
                                                            .name
                                                            // .productName
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData.grey50
                                                              : AppThemeData
                                                                  .grey900,
                                                          fontFamily:
                                                              AppThemeData.semiBold,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    
                                                            Text(
                                                   " (${controller.menuList[index]
                                                        .name_2
                                                        // .productDescription
                                                        .toString()})",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey50
                                                          : AppThemeData
                                                              .grey900,
                                                      fontFamily:
                                                          AppThemeData.regular,
                                                    ),
                                                  ),
                                                    ],
                                                  ),
                                                  
                                                  double.parse(disPrice) <= 0
                                                      ? Text(
                                                          Constant.amountShow(
                                                              amount: price),
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .grey50
                                                                : AppThemeData
                                                                    .grey900,
                                                            fontFamily:
                                                                AppThemeData
                                                                    .semiBold,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        )
                                                      : Row(
                                                          children: [
                                                            Text(
                                                              Constant.amountShow(
                                                                  amount:
                                                                      disPrice),
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: themeChange
                                                                        .getThem()
                                                                    ? AppThemeData
                                                                        .grey50
                                                                    : AppThemeData
                                                                        .grey900,
                                                                fontFamily:
                                                                    AppThemeData
                                                                        .semiBold,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              Constant
                                                                  .amountShow(
                                                                      amount:
                                                                          price),
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                                decorationColor: themeChange.getThem()
                                                                    ? AppThemeData
                                                                        .grey500
                                                                    : AppThemeData
                                                                        .grey400,
                                                                color: themeChange.getThem()
                                                                    ? AppThemeData
                                                                        .grey500
                                                                    : AppThemeData
                                                                        .grey400,
                                                                fontFamily:
                                                                    AppThemeData
                                                                        .semiBold,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                  // Text(
                                                  //   controller.menuList[index]
                                                  //       .description
                                                  //       // .productDescription
                                                  //       .toString(),
                                                  //   maxLines: 1,
                                                  //   style: TextStyle(
                                                  //     fontSize: 12,
                                                  //     color: themeChange
                                                  //             .getThem()
                                                  //         ? AppThemeData.grey50
                                                  //         : AppThemeData
                                                  //             .grey900,
                                                  //     fontFamily:
                                                  //         AppThemeData.regular,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  ShowToastDialog.showLoader(
                                                      "Please wait..");

                                                  bool success =
                                                      await FireStoreUtils
                                                          .deleteProductFromMenu(
                                                              controller.menuList[index]);

                                                  ShowToastDialog.closeLoader();

                                                  if (success) {
                                                    ShowToastDialog.showToast(
                                                        "Product deleted successfully");
                                                    controller.getMenu();
                                                  } else {
                                                    ShowToastDialog.showToast(
                                                        "Failed to delete Product");
                                                  }
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                        "assets/icons/ic_delete-one.svg"),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      "Delete".tr,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color:
                                                              themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .danger300
                                                                  : AppThemeData
                                                                      .danger300,
                                                          fontSize: 16,
                                                          fontFamily:
                                                              AppThemeData
                                                                  .bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  Get.to(
                                                          () =>
                                                              const AddMenuScreen(),
                                                          arguments: {
                                                        "productModel":
                                                            controller
                                                                .menuList[index]
                                                      })!
                                                      .then((value) {
                                                    if (value == true) {
                                                      controller.getMenu();
                                                    }
                                                  });
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Edit".tr,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .grey100
                                                            : AppThemeData
                                                                .grey800,
                                                        fontSize: 16,
                                                        fontFamily:
                                                            AppThemeData.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )),
            ),
          );
        });
  }
}
