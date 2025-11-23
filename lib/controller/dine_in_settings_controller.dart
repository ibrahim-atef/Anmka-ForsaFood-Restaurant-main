import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/models/dine_in_settings_model.dart';
import 'package:restaurant/models/vendor_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class DineInSettingsController extends GetxController {
  Rx<VendorModel> vendorModel = VendorModel().obs;
  Rx<DineInSettingsModel> dineInSettings = DineInSettingsModel().obs;
  
  RxBool isLoading = true.obs;
  RxInt minGuests = 1.obs;
  RxInt maxGuests = 20.obs;
  RxString defaultDiscount = "0".obs;
  
  Rx<TextEditingController> minGuestsController = TextEditingController().obs;
  Rx<TextEditingController> maxGuestsController = TextEditingController().obs;
  Rx<TextEditingController> defaultDiscountController = TextEditingController().obs;

  List<String> daysOfWeek = [
    "Monday",
    "Tuesday", 
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  getData() async {
    await FireStoreUtils.getVendorById(Constant.userModel!.vendorID.toString()).then(
      (value) {
        if (value != null) {
          vendorModel.value = value;
          
          // Initialize dine in settings if not exists
          if (vendorModel.value.dineInSettings == null) {
            dineInSettings.value = DineInSettingsModel(
              isEnabled: vendorModel.value.enabledDiveInFuture ?? false,
              minGuests: 1,
              maxGuests: 20,
              defaultDiscount: "0",
              daysSettings: daysOfWeek.map((day) {
                return DineInDaySettings(
                  day: day,
                  isEnabled: false,
                  timeSlots: [],
                );
              }).toList(),
            );
          } else {
            dineInSettings.value = vendorModel.value.dineInSettings!;
            // Ensure all days are present
            if (dineInSettings.value.daysSettings == null || 
                dineInSettings.value.daysSettings!.length < daysOfWeek.length) {
              dineInSettings.value.daysSettings ??= [];
              for (var day in daysOfWeek) {
                if (!dineInSettings.value.daysSettings!.any((d) => d.day == day)) {
                  dineInSettings.value.daysSettings!.add(
                    DineInDaySettings(day: day, isEnabled: false, timeSlots: []),
                  );
                }
              }
            }
          }
          
          minGuests.value = dineInSettings.value.minGuests ?? 1;
          maxGuests.value = dineInSettings.value.maxGuests ?? 20;
          defaultDiscount.value = dineInSettings.value.defaultDiscount ?? "0";
          
          minGuestsController.value.text = minGuests.value.toString();
          maxGuestsController.value.text = maxGuests.value.toString();
          defaultDiscountController.value.text = defaultDiscount.value;
        }
      },
    );
    isLoading.value = false;
  }

  void toggleDay(int index) {
    if (dineInSettings.value.daysSettings == null) {
      dineInSettings.value.daysSettings = [];
    }
    
    // Ensure day exists
    while (dineInSettings.value.daysSettings!.length <= index) {
      dineInSettings.value.daysSettings!.add(
        DineInDaySettings(
          day: daysOfWeek[dineInSettings.value.daysSettings!.length],
          isEnabled: false,
          timeSlots: [],
        ),
      );
    }
    
    // Get current state
    final currentState = dineInSettings.value.daysSettings![index].isEnabled ?? false;
    
    // Create new list with updated day
    final updatedDays = <DineInDaySettings>[];
    for (int i = 0; i < dineInSettings.value.daysSettings!.length; i++) {
      if (i == index) {
        updatedDays.add(DineInDaySettings(
          day: dineInSettings.value.daysSettings![i].day,
          isEnabled: !currentState,
          timeSlots: List.from(dineInSettings.value.daysSettings![i].timeSlots ?? []),
        ));
      } else {
        updatedDays.add(DineInDaySettings(
          day: dineInSettings.value.daysSettings![i].day,
          isEnabled: dineInSettings.value.daysSettings![i].isEnabled,
          timeSlots: List.from(dineInSettings.value.daysSettings![i].timeSlots ?? []),
        ));
      }
    }
    
    // Create new instance to trigger reactive update
    dineInSettings.value = DineInSettingsModel(
      isEnabled: dineInSettings.value.isEnabled,
      minGuests: dineInSettings.value.minGuests,
      maxGuests: dineInSettings.value.maxGuests,
      defaultDiscount: dineInSettings.value.defaultDiscount,
      daysSettings: updatedDays,
    );
  }

  void addTimeSlot(int dayIndex) {
    if (dineInSettings.value.daysSettings == null) {
      dineInSettings.value.daysSettings = [];
    }
    
    // Ensure day exists
    while (dayIndex >= dineInSettings.value.daysSettings!.length) {
      dineInSettings.value.daysSettings!.add(
        DineInDaySettings(
          day: daysOfWeek[dineInSettings.value.daysSettings!.length],
          isEnabled: false,
          timeSlots: [],
        ),
      );
    }
    
    // Create new time slot
    final newTimeSlot = DineInTimeSlot(
      from: "10:00 AM",
      to: "11:00 PM",
      discount: defaultDiscount.value,
      discountType: "percentage",
      minGuests: minGuests.value,
      maxGuests: maxGuests.value,
    );
    
    // Create updated days list
    final updatedDays = <DineInDaySettings>[];
    for (int i = 0; i < dineInSettings.value.daysSettings!.length; i++) {
      if (i == dayIndex) {
        final currentSlots = List<DineInTimeSlot>.from(dineInSettings.value.daysSettings![i].timeSlots ?? []);
        currentSlots.add(newTimeSlot);
        updatedDays.add(DineInDaySettings(
          day: dineInSettings.value.daysSettings![i].day,
          isEnabled: dineInSettings.value.daysSettings![i].isEnabled,
          timeSlots: currentSlots,
        ));
      } else {
        updatedDays.add(DineInDaySettings(
          day: dineInSettings.value.daysSettings![i].day,
          isEnabled: dineInSettings.value.daysSettings![i].isEnabled,
          timeSlots: List.from(dineInSettings.value.daysSettings![i].timeSlots ?? []),
        ));
      }
    }
    
    // Create new instance to trigger reactive update
    dineInSettings.value = DineInSettingsModel(
      isEnabled: dineInSettings.value.isEnabled,
      minGuests: dineInSettings.value.minGuests,
      maxGuests: dineInSettings.value.maxGuests,
      defaultDiscount: dineInSettings.value.defaultDiscount,
      daysSettings: updatedDays,
    );
  }

  void removeTimeSlot(int dayIndex, int slotIndex) {
    if (dineInSettings.value.daysSettings != null &&
        dayIndex < dineInSettings.value.daysSettings!.length) {
      
      // Create updated days list
      final updatedDays = <DineInDaySettings>[];
      for (int i = 0; i < dineInSettings.value.daysSettings!.length; i++) {
        if (i == dayIndex) {
          final currentSlots = List<DineInTimeSlot>.from(dineInSettings.value.daysSettings![i].timeSlots ?? []);
          if (slotIndex < currentSlots.length) {
            currentSlots.removeAt(slotIndex);
          }
          updatedDays.add(DineInDaySettings(
            day: dineInSettings.value.daysSettings![i].day,
            isEnabled: dineInSettings.value.daysSettings![i].isEnabled,
            timeSlots: currentSlots,
          ));
        } else {
          updatedDays.add(DineInDaySettings(
            day: dineInSettings.value.daysSettings![i].day,
            isEnabled: dineInSettings.value.daysSettings![i].isEnabled,
            timeSlots: List.from(dineInSettings.value.daysSettings![i].timeSlots ?? []),
          ));
        }
      }
      
      // Create new instance to trigger reactive update
      dineInSettings.value = DineInSettingsModel(
        isEnabled: dineInSettings.value.isEnabled,
        minGuests: dineInSettings.value.minGuests,
        maxGuests: dineInSettings.value.maxGuests,
        defaultDiscount: dineInSettings.value.defaultDiscount,
        daysSettings: updatedDays,
      );
    }
  }

  void updateTimeSlot(int dayIndex, int slotIndex, DineInTimeSlot updatedSlot) {
    if (dineInSettings.value.daysSettings != null &&
        dayIndex < dineInSettings.value.daysSettings!.length &&
        slotIndex < (dineInSettings.value.daysSettings![dayIndex].timeSlots?.length ?? 0)) {
      
      // Create updated days list
      final updatedDays = <DineInDaySettings>[];
      for (int i = 0; i < dineInSettings.value.daysSettings!.length; i++) {
        if (i == dayIndex) {
          final currentSlots = List<DineInTimeSlot>.from(dineInSettings.value.daysSettings![i].timeSlots ?? []);
          if (slotIndex < currentSlots.length) {
            currentSlots[slotIndex] = updatedSlot;
          }
          updatedDays.add(DineInDaySettings(
            day: dineInSettings.value.daysSettings![i].day,
            isEnabled: dineInSettings.value.daysSettings![i].isEnabled,
            timeSlots: currentSlots,
          ));
        } else {
          updatedDays.add(DineInDaySettings(
            day: dineInSettings.value.daysSettings![i].day,
            isEnabled: dineInSettings.value.daysSettings![i].isEnabled,
            timeSlots: List.from(dineInSettings.value.daysSettings![i].timeSlots ?? []),
          ));
        }
      }
      
      // Create new instance to trigger reactive update
      dineInSettings.value = DineInSettingsModel(
        isEnabled: dineInSettings.value.isEnabled,
        minGuests: dineInSettings.value.minGuests,
        maxGuests: dineInSettings.value.maxGuests,
        defaultDiscount: dineInSettings.value.defaultDiscount,
        daysSettings: updatedDays,
      );
    }
  }

  Future<void> selectTime(BuildContext context, Function(String) onTimeSelected) async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    if (pickedTime != null) {
      final timeString = pickedTime.format(context);
      onTimeSelected(timeString);
    }
  }

  saveSettings() async {
    ShowToastDialog.showLoader("Please wait..".tr);
    
    dineInSettings.value.isEnabled = dineInSettings.value.isEnabled ?? false;
    dineInSettings.value.minGuests = minGuests.value;
    dineInSettings.value.maxGuests = maxGuests.value;
    dineInSettings.value.defaultDiscount = defaultDiscount.value;
    
    vendorModel.value.dineInSettings = dineInSettings.value;
    vendorModel.value.enabledDiveInFuture = dineInSettings.value.isEnabled;
    
    await FireStoreUtils.updateVendor(vendorModel.value).then((value) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Dine In Settings saved successfully".tr);
      Get.back();
    });
  }
}

