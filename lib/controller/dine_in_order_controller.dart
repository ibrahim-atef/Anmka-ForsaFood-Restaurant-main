import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:restaurant/constant/collection_name.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/models/dine_in_booking_model.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/models/vendor_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class DineInOrderController extends GetxController{

  RxBool isLoading  = true.obs;
  RxInt selectedTabIndex = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getUserProfile();
    super.onInit();
  }

  @override
  void onClose() {
    // Cancel listeners when controller is disposed
    super.onClose();
  }

  Rx<UserModel> userModel = UserModel().obs;
  Rx<VendorModel> vendorModel = VendorModel().obs;

  RxList<DineInBookingModel> featureList = <DineInBookingModel>[].obs;
  RxList<DineInBookingModel> historyList = <DineInBookingModel>[].obs;

  getUserProfile() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then(
          (value) {
        if (value != null) {
          userModel.value = value;
        }
      },
    );

    if(Constant.userModel!.vendorID != null && Constant.userModel!.vendorID!.isNotEmpty){
      await FireStoreUtils.getVendorById(Constant.userModel!.vendorID.toString()).then(
            (value) {
          if (value != null) {
            vendorModel.value = value;
            print("📋 Vendor dineInSettings: ${value.dineInSettings?.isEnabled}");
          }
        },
      );

      await getDineBooking();
    }


    isLoading.value = false;
  }
  
  // Method to refresh vendor data
  refreshVendorData() async {
    if(Constant.userModel?.vendorID != null && Constant.userModel!.vendorID!.isNotEmpty){
      await FireStoreUtils.getVendorById(Constant.userModel!.vendorID.toString()).then(
            (value) {
          if (value != null) {
            vendorModel.value = value;
            update();
          }
        },
      );
    }
  }

  getDineBooking() async {
    print("🔄 Getting Dine In bookings...");
    print("📋 VendorID: ${Constant.userModel?.vendorID}");
    
    if (Constant.userModel?.vendorID == null || Constant.userModel!.vendorID!.isEmpty) {
      print("⚠️ Cannot fetch bookings: vendorID is null or empty");
      featureList.clear();
      historyList.clear();
      return;
    }
    
    await FireStoreUtils.getDineInBooking(true).then(
          (value) {
        print("✅ Upcoming bookings: ${value.length}");
        featureList.value = value;
        update();
      },
    ).catchError((error) {
      print("❌ Error getting upcoming bookings: $error");
      featureList.clear();
    });
    
    await FireStoreUtils.getDineInBooking(false).then(
          (value) {
        print("✅ History bookings: ${value.length}");
        historyList.value = value;
        update();
      },
    ).catchError((error) {
      print("❌ Error getting history bookings: $error");
      historyList.clear();
    });
  }

}