import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:restaurant/app/Home_screen/home_screen.dart';
import 'package:restaurant/app/dine_in_order_screen/dine_in_order_screen.dart';
import 'package:restaurant/app/product_screens/product_list_screen.dart';
import 'package:restaurant/app/profile_screen/profile_screen.dart';
import 'package:restaurant/app/wallet_screen/wallet_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class DashBoardController extends GetxController {
  RxInt selectedIndex = 0.obs;

  RxList pageList = [].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    setSound();
    getVendor();
    setPage();

    super.onInit();
  }

  setPage(){
    pageList.value = Constant.isDineInEnable && Constant.userModel!.subscriptionPlan?.features?.dineIn != false
        ? [
      const HomeScreen(),
      // const DineInOrderScreen(),
      const ProductListScreen(),
      // const WalletScreen(),
      const ProfileScreen(),
    ]
        : [
      const HomeScreen(),
      const ProductListScreen(),
      // const WalletScreen(),
      const ProfileScreen(),
    ];

      if (selectedIndex.value >= pageList.length) {
    print("⚠️ selectedIndex (${selectedIndex.value}) too high, resetting to 0");
    selectedIndex.value = 0;
  }
  }
  getVendor() async {
    if (Constant.userModel!.vendorID != null) {
      await FireStoreUtils.getVendorById(Constant.userModel!.vendorID.toString()).then(
        (value) {
          if (value != null) {
            Constant.vendorAdminCommission = value.adminCommission;
          }
        },
      );
    }
  }

  DateTime? currentBackPressTime;
  RxBool canPopNow = false.obs;

  setSound() async {
    try {
      print("--------->${audioPlayer.state}");
      audioPlayer.setSource(AssetSource("sound.mp3"));
      audioPlayer.setReleaseMode(ReleaseMode.loop);
      audioPlayer.stop();
      print("--------->${audioPlayer.state}");
    } catch (e) {
      print("--------->$e");
    }
  }
}
