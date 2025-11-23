import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant/constant/collection_name.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/models/driver_document_model.dart';
import 'package:restaurant/models/order_model.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/models/vendor_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class HomeController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<TextEditingController> estimatedTimeController = TextEditingController().obs;

  RxInt selectedTabIndex = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getUserProfile();
    super.onInit();
  }

  RxList<OrderModel> allOrderList = <OrderModel>[].obs;
  RxList<OrderModel> newOrderList = <OrderModel>[].obs;
  RxList<OrderModel> acceptedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> completedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> rejectedOrderList = <OrderModel>[].obs;

  Rx<UserModel> userModel = UserModel().obs;
  Rx<VendorModel> vendermodel = VendorModel().obs;

  getUserProfile() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then(
      (value) {
        if (value != null) {
          userModel.value = value;
        }
      },
    );
    if (userModel.value.vendorID != null) {
      await FireStoreUtils.getVendorById(userModel.value.vendorID!).then(
        (vender) {
          if (vender?.id != null) {
            vendermodel.value = vender!;
          }
        },
      );
    }
    // Check document verification status
    await checkDocumentVerificationStatus();
    await getOrder();
    isLoading.value = false;
  }

  checkDocumentVerificationStatus() async {
    if (Constant.isRestaurantVerification == true) {
      try {
        // Get document list and driver documents
        final documentList = await FireStoreUtils.getDocumentList();
        final driverDocumentData = await FireStoreUtils.getDocumentOfDriver();
        
        if (documentList.isNotEmpty && driverDocumentData != null && driverDocumentData.documents != null) {
          // Check if all required documents are approved
          bool allApproved = true;
          bool hasUploadedDocuments = false;
          
          for (var docModel in documentList) {
            var driverDoc = driverDocumentData.documents!.firstWhere(
              (doc) => doc.documentId == docModel.id,
              orElse: () => Documents(status: "pending"),
            );
            
            // Check if document is uploaded (not pending)
            if (driverDoc.status != null && driverDoc.status != "pending") {
              hasUploadedDocuments = true;
              
              // If document is uploaded but not approved, then not all are approved
              if (driverDoc.status != "approved") {
                allApproved = false;
              }
            }
          }
          
          // Update isDocumentVerify if all uploaded documents are approved
          // Only update if there are uploaded documents and all are approved
          if (hasUploadedDocuments && allApproved) {
            if (userModel.value.isDocumentVerify != true) {
              userModel.value.isDocumentVerify = true;
              await FireStoreUtils.updateUser(userModel.value);
              Constant.userModel = userModel.value;
              update(); // Refresh UI
            }
          }
        }
      } catch (e) {
        print("Error checking document verification status: $e");
      }
    }
  }

  getOrder() async {
    FireStoreUtils.fireStore
        .collection(CollectionName.restaurantOrders)
        .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (event) {
        allOrderList.clear();
        for (var element in event.docs) {
          OrderModel orderModel = OrderModel.fromJson(element.data());
          allOrderList.add(orderModel);
          if (allOrderList.first.status == Constant.orderPlaced) {
            playSound(true);
          } else {
            playSound(false);
          }

          newOrderList.value = allOrderList.where((p0) => p0.status == Constant.orderPlaced).toList();
          acceptedOrderList.value = allOrderList
              .where((p0) =>
                  p0.status == Constant.orderAccepted ||
                  p0.status == Constant.driverPending ||
                  p0.status == Constant.driverRejected ||
                  p0.status == Constant.orderShipped ||
                  p0.status == Constant.orderInTransit)
              .toList();
          completedOrderList.value = allOrderList.where((p0) => p0.status == Constant.orderCompleted).toList();
          rejectedOrderList.value = allOrderList.where((p0) => p0.status == Constant.orderRejected).toList();
        }
      },
    );
  }

  playSound(bool isPlay) async {
    if (isPlay) {
      await audioPlayer.resume();
    } else {
      await audioPlayer.stop();
    }
    print("0--------->${audioPlayer.state}");
  }

  @override
  void dispose() {
    playSound(false);
    super.dispose();
  }

  @override
  void onClose() {
    playSound(false);
    super.onClose();
  }
}
