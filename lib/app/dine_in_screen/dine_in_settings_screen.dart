import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/controller/dine_in_settings_controller.dart';
import 'package:restaurant/models/dine_in_settings_model.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/themes/text_field_widget.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';

class DineInSettingsScreen extends StatelessWidget {
  const DineInSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: DineInSettingsController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppThemeData.secondary300,
            centerTitle: false,
            titleSpacing: 0,
            iconTheme: const IconThemeData(color: AppThemeData.grey50, size: 20),
            title: Text(
              "Dine In Settings".tr,
              style: TextStyle(
                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                fontSize: 18,
                fontFamily: AppThemeData.medium,
              ),
            ),
          ),
          body: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enable/Disable Dine In
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Enable Dine In".tr,
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                fontSize: 18,
                                fontFamily: AppThemeData.medium,
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: Obx(() {
                              final isEnabled = controller.dineInSettings.value.isEnabled ?? false;
                              return CupertinoSwitch(
                                value: isEnabled,
                                onChanged: (value) {
                                  // Create new instance to trigger reactive update
                                  controller.dineInSettings.value = DineInSettingsModel(
                                    isEnabled: value,
                                    minGuests: controller.dineInSettings.value.minGuests,
                                    maxGuests: controller.dineInSettings.value.maxGuests,
                                    defaultDiscount: controller.dineInSettings.value.defaultDiscount,
                                    daysSettings: List.from(controller.dineInSettings.value.daysSettings ?? []),
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Min/Max Guests
                      Text(
                        "Number of Guests".tr,
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                          fontSize: 16,
                          fontFamily: AppThemeData.semiBold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFieldWidget(
                              title: "Min Guests".tr,
                              controller: controller.minGuestsController.value,
                              hintText: "1",
                              textInputType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onchange: (value) {
                                if (value.isNotEmpty) {
                                  controller.minGuests.value = int.parse(value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFieldWidget(
                              title: "Max Guests".tr,
                              controller: controller.maxGuestsController.value,
                              hintText: "20",
                              textInputType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onchange: (value) {
                                if (value.isNotEmpty) {
                                  controller.maxGuests.value = int.parse(value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Default Discount
                      TextFieldWidget(
                        title: "Default Discount (%)".tr,
                        controller: controller.defaultDiscountController.value,
                        hintText: "0",
                        textInputType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                        onchange: (value) {
                          controller.defaultDiscount.value = value;
                        },
                      ),
                      const SizedBox(height: 30),
                      
                      // Days Settings
                      Text(
                        "Days & Time Settings".tr,
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                          fontSize: 18,
                          fontFamily: AppThemeData.semiBold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Days List
                      ...List.generate(
                        controller.daysOfWeek.length,
                        (dayIndex) {
                          final day = controller.daysOfWeek[dayIndex];
                          
                          return Obx(() {
                            // Find day settings or create new one - read fresh from controller
                            final currentSettings = controller.dineInSettings.value;
                            DineInDaySettings daySettings;
                            
                            if (currentSettings.daysSettings != null &&
                                dayIndex < currentSettings.daysSettings!.length) {
                              daySettings = currentSettings.daysSettings![dayIndex];
                            } else {
                              daySettings = DineInDaySettings(day: day, isEnabled: false, timeSlots: []);
                              // Don't modify here, let controller handle it
                            }
                            
                            final isDayEnabled = daySettings.isEnabled ?? false;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          day.tr,
                                          style: TextStyle(
                                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                            fontSize: 16,
                                            fontFamily: AppThemeData.semiBold,
                                          ),
                                        ),
                                      ),
                                      Transform.scale(
                                        scale: 0.8,
                                        child: CupertinoSwitch(
                                          value: isDayEnabled,
                                          onChanged: (value) {
                                            controller.toggleDay(dayIndex);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  if (isDayEnabled) ...[
                                    const SizedBox(height: 15),
                                    
                                    // Time Slots - read fresh from controller
                                    if (daySettings.timeSlots != null && daySettings.timeSlots!.isNotEmpty)
                                      ...daySettings.timeSlots!.asMap().entries.map((entry) {
                                        final slotIndex = entry.key;
                                        final slot = entry.value;
                                        return _buildTimeSlot(
                                          context,
                                          themeChange,
                                          controller,
                                          dayIndex,
                                          slotIndex,
                                          slot,
                                        );
                                      }).toList(),
                                  
                                  const SizedBox(height: 10),
                                  
                                  // Add Time Slot Button
                                  InkWell(
                                    onTap: () {
                                      controller.addTimeSlot(dayIndex);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppThemeData.secondary300,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: AppThemeData.secondary300,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Add Time Slot".tr,
                                            style: TextStyle(
                                              color: AppThemeData.secondary300,
                                              fontSize: 14,
                                              fontFamily: AppThemeData.semiBold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );})

                    ],
                  ),
                ),
            bottomNavigationBar: Container(
            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: RoundedButtonFill(
              title: "Save Settings".tr,
              height: 5.5,
              color: AppThemeData.secondary300,
              textColor: AppThemeData.grey50,
              fontSizes: 16,
              onPress: () {
                controller.saveSettings();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSlot(
    BuildContext context,
    DarkThemeProvider themeChange,
    DineInSettingsController controller,
    int dayIndex,
    int slotIndex,
    DineInTimeSlot slot,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    await controller.selectTime(context, (time) {
                      slot.from = time;
                      controller.updateTimeSlot(dayIndex, slotIndex, slot);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/ic_alarm-clock.svg",
                          colorFilter: ColorFilter.mode(
                            themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey800,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          slot.from ?? "From".tr,
                          style: TextStyle(
                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            fontFamily: AppThemeData.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    await controller.selectTime(context, (time) {
                      slot.to = time;
                      controller.updateTimeSlot(dayIndex, slotIndex, slot);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/ic_alarm-clock.svg",
                          colorFilter: ColorFilter.mode(
                            themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey800,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          slot.to ?? "To".tr,
                          style: TextStyle(
                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            fontFamily: AppThemeData.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  controller.removeTimeSlot(dayIndex, slotIndex);
                },
                child: Icon(
                  Icons.delete_outline,
                  color: AppThemeData.danger300,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFieldWidget(
                  title: "Discount (%)".tr,
                  controller: TextEditingController(text: slot.discount ?? "0")..selection = TextSelection.fromPosition(TextPosition(offset: (slot.discount ?? "0").length)),
                  hintText: "0",
                  textInputType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  onchange: (value) {
                    slot.discount = value.isEmpty ? "0" : value;
                    controller.updateTimeSlot(dayIndex, slotIndex, slot);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFieldWidget(
                  title: "Min Guests".tr,
                  controller: TextEditingController(text: (slot.minGuests ?? controller.minGuests.value).toString())..selection = TextSelection.fromPosition(TextPosition(offset: (slot.minGuests ?? controller.minGuests.value).toString().length)),
                  hintText: "1",
                  textInputType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onchange: (value) {
                    if (value.isNotEmpty) {
                      slot.minGuests = int.parse(value);
                      controller.updateTimeSlot(dayIndex, slotIndex, slot);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFieldWidget(
                  title: "Max Guests".tr,
                  controller: TextEditingController(text: (slot.maxGuests ?? controller.maxGuests.value).toString())..selection = TextSelection.fromPosition(TextPosition(offset: (slot.maxGuests ?? controller.maxGuests.value).toString().length)),
                  hintText: "20",
                  textInputType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onchange: (value) {
                    if (value.isNotEmpty) {
                      slot.maxGuests = int.parse(value);
                      controller.updateTimeSlot(dayIndex, slotIndex, slot);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

