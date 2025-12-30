import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:restaurant/app/Home_screen/order_details_screen.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/controller/scan_order_qr_controller.dart';
import 'package:restaurant/models/order_model.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';

class ScanOrderQrScreen extends StatelessWidget {
  const ScanOrderQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final controller = Get.put(ScanOrderQrController());
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
        title: Text(
          "Scan Order QR Code".tr,
          style: TextStyle(
            fontSize: 16,
            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
            fontFamily: AppThemeData.medium,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Obx(() {
        // Use isLoading to make Obx reactive
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return QRCodeDartScanView(
          onCapture: (Result result) async {
            // The QR code should contain order ID
            String orderId = result.text.trim();
            
            if (orderId.isEmpty) {
              ShowToastDialog.showToast("Invalid QR code".tr);
              return;
            }
            
            // Fetch order by ID - this will set isLoading to true
            OrderModel? orderModel = await controller.getOrderById(orderId);
            
            if (orderModel != null) {
              // Close scanner and navigate to order details
              Get.back();
              Get.to(const OrderDetailsScreen(), arguments: {"orderModel": orderModel});
            } else {
              ShowToastDialog.showToast("Order not found".tr);
            }
          },
        );
      }),
    );
  }
}


