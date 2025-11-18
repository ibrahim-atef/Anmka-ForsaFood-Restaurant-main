import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/models/vendor_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class WorkingHoursController extends GetxController{

  RxBool isLoading = true.obs;
  RxList<WorkingHours> workingHours = <WorkingHours>[].obs;


  @override
  void onInit() {
    // TODO: implement onInit
    getVendor();
    super.onInit();
  }

  Rx<VendorModel> vendorModel = VendorModel().obs;

 getVendor() async {
  print("🔍 Start fetching vendor data...");
  
  String vendorID = Constant.userModel?.vendorID ?? 'NO_VENDOR_ID';
  print("📦 vendorID: $vendorID");

  isLoading.value = true;

  try {
    var value = await FireStoreUtils.getVendorById(vendorID);
    
    if (value != null) {
      print("✅ Vendor data fetched successfully.");
      vendorModel.value = value;

      if (value.workingHours == null || value.workingHours!.isEmpty) {
        print("⚠️ No working hours found in vendor. Setting default.");
        workingHours.value = [
          WorkingHours(day: 'Monday'.tr, timeslot: []),
          WorkingHours(day: 'Tuesday'.tr, timeslot: []),
          WorkingHours(day: 'Wednesday'.tr, timeslot: []),
          WorkingHours(day: 'Thursday'.tr, timeslot: []),
          WorkingHours(day: 'Friday'.tr, timeslot: []),
          WorkingHours(day: 'Saturday'.tr, timeslot: []),
          WorkingHours(day: 'Sunday'.tr, timeslot: [])
        ];
      } else {
        print("🕒 Loaded working hours from vendor:");
        for (var i = 0; i < value.workingHours!.length; i++) {
          final day = value.workingHours![i];
          print("📅 ${day.day}:");
          for (var time in day.timeslot!) {
            print("    From: ${time.from}, To: ${time.to}");
          }
        }

        workingHours.value = value.workingHours!;
      }
    } else {
      print("❌ Vendor not found (null). Setting default working hours.");
      workingHours.value = [
        WorkingHours(day: 'Monday'.tr, timeslot: []),
        WorkingHours(day: 'Tuesday'.tr, timeslot: []),
        WorkingHours(day: 'Wednesday'.tr, timeslot: []),
        WorkingHours(day: 'Thursday'.tr, timeslot: []),
        WorkingHours(day: 'Friday'.tr, timeslot: []),
        WorkingHours(day: 'Saturday'.tr, timeslot: []),
        WorkingHours(day: 'Sunday'.tr, timeslot: []),
      ];
    }

    print("📊 Final workingHours.length: ${workingHours.length}");

  } catch (e, s) {
    print("🛑 Exception while fetching vendor: $e");
    print("📌 Stacktrace:\n$s");
  } finally {
    isLoading.value = false;
    print("🔚 getVendor() done");
  }
}


  saveSpecialOffer() async {
    ShowToastDialog.showLoader("Please wait");

    FocusScope.of(Get.context!).requestFocus(FocusNode()); //remove focus
    vendorModel.value.workingHours = workingHours;

    await FireStoreUtils.updateVendor(vendorModel.value).then((value) async {
      ShowToastDialog.showToast("Working hours update successfully");
      ShowToastDialog.closeLoader();
    });
  }

  addValue(int index) {
    WorkingHours specialDiscountModel = workingHours[index];
    specialDiscountModel.timeslot!.add(Timeslot(from: '', to: ''));
    workingHours.removeAt(index);
    workingHours.insert(index, specialDiscountModel);
    update();
  }

  remove(int index, int timeSlotIndex) {
    WorkingHours specialDiscountModel = workingHours[index];
    specialDiscountModel.timeslot!.removeAt(timeSlotIndex);
    workingHours.removeAt(index);
    workingHours.insert(index, specialDiscountModel);
    update();
    update();
  }



}