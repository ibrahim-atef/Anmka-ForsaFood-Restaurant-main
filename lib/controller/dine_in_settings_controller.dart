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
  RxInt totalTables = 10.obs;
  
  Rx<TextEditingController> minGuestsController = TextEditingController().obs;
  Rx<TextEditingController> maxGuestsController = TextEditingController().obs;
  Rx<TextEditingController> defaultDiscountController = TextEditingController().obs;
  Rx<TextEditingController> totalTablesController = TextEditingController().obs;

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
              totalTables: 10,
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
          totalTables.value = dineInSettings.value.totalTables ?? 10;
          
          minGuestsController.value.text = minGuests.value.toString();
          maxGuestsController.value.text = maxGuests.value.toString();
          defaultDiscountController.value.text = defaultDiscount.value;
          totalTablesController.value.text = totalTables.value.toString();
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
      
      // Validate time - start should be before end
      if (updatedSlot.from != null && updatedSlot.to != null) {
        try {
          DateTime? startTime = _parseTime(updatedSlot.from!);
          DateTime? endTime = _parseTime(updatedSlot.to!);
          if (startTime != null && endTime != null && startTime.isAfter(endTime)) {
            ShowToastDialog.showToast("Start time must be before end time".tr);
            return;
          }
        } catch (e) {
          print("Error parsing time: $e");
        }
      }
      
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
  
  // Helper function to parse time string
  DateTime? _parseTime(String timeStr) {
    try {
      return DateFormat('h:mm a').parse(timeStr);
    } catch (e) {
      try {
        return DateFormat('hh:mm a').parse(timeStr);
      } catch (e2) {
        return null;
      }
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
    // Validate min/max guests
    if (minGuests.value > maxGuests.value) {
      ShowToastDialog.showToast("Min guests cannot be greater than max guests".tr);
      return;
    }
    
    // Validate default discount (ensure it's not negative)
    double? discountValue = double.tryParse(defaultDiscount.value);
    if (discountValue == null || discountValue < 0) {
      defaultDiscount.value = "0";
      defaultDiscountController.value.text = "0";
    }
    
    ShowToastDialog.showLoader("Please wait..".tr);
    
    // Create new instance with all values to ensure totalTables is saved
    dineInSettings.value = DineInSettingsModel(
      isEnabled: dineInSettings.value.isEnabled ?? false,
      minGuests: minGuests.value,
      maxGuests: maxGuests.value,
      defaultDiscount: defaultDiscount.value,
      totalTables: totalTables.value,
      daysSettings: dineInSettings.value.daysSettings,
    );
    
    vendorModel.value.dineInSettings = dineInSettings.value;
    vendorModel.value.enabledDiveInFuture = dineInSettings.value.isEnabled;
    
    await FireStoreUtils.updateVendor(vendorModel.value).then((value) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Dine In Settings saved successfully".tr);
      Get.back();
    });
  }
}

