import 'package:get/get.dart';
import 'package:restaurant/models/order_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/constant/collection_name.dart';

class ScanOrderQrController extends GetxController {
  RxBool isLoading = false.obs;

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      isLoading.value = true;
      
      var doc = await FireStoreUtils.fireStore
          .collection(CollectionName.restaurantOrders)
          .doc(orderId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        OrderModel orderModel = OrderModel.fromJson(doc.data()!);
        return orderModel;
      }
      
      return null;
    } catch (e) {
      print("Error fetching order: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}











