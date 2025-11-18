import 'package:get/get.dart';
import 'package:restaurant/models/menu_model.dart';
import 'package:restaurant/models/product_model.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class MenuListController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    getUserProfile();
    super.onInit();
  }

  Rx<UserModel> userModel = UserModel().obs;
  RxBool isLoading = true.obs;

  getUserProfile() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then(
      (value) {
        if (value != null) {
          userModel.value = value;
        }
      },
    );
    await getMenu();

    isLoading.value = false;
  }

  // RxList<ProductModel> productList = <ProductModel>[].obs;

  RxList<ProductModel> menuList = <ProductModel>[].obs;
  // RxList<MenuModel> menuList = <MenuModel>[].obs;
  Rx<ProductModel> menuModels = ProductModel().obs;
  // Rx<MenuModel> menuModels = MenuModel().obs;

getMenu() async {
  isLoading.value = true;
  try {
    print("🔄 Loading menu...");
    List<ProductModel> model = await FireStoreUtils.getMenuForUser();

    print("✅ getMenu - Fetched ${model.length} items");

    // اطبع كل عنصر من القائمة
    for (int i = 0; i < model.length; i++) {
      print("📦 Item $i => ${model[i].toJson()}");
    }

    menuList.value = model;
  } catch (e, stack) {
    print("❌ Error fetching menu: $e");
    print("📌 Stacktrace:\n$stack");
  }
  isLoading.value = false;
}


  // updateList(int index,bool isPublish)  async {
  //   MenuModel productModel = menuModel[index];

  //   menuModel.removeAt(index);
  //   menuModel.insert(index,menuModel);
  //   update();
  //   await FireStoreUtils.setProduct(men);
  // }
}
