import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant/models/admin_commission.dart';
import 'package:restaurant/models/subscription_plan_model.dart';

class MenuModel {
  String? productId;
  String? menuId;
  String? documentId;
  String? productName;
  String? productDescription;
  String? productPhoto;
  String? categorId;
  String? productPrice;

  MenuModel({
    this.productId,
    this.menuId,
    this.documentId,
    this.productName,
    this.productDescription,
    this.productPhoto,
    this.categorId,
    this.productPrice,
  });

  MenuModel.fromJson(Map<String, dynamic> json) {
    productId = json['id'];
    menuId = json['menu_id'];
    categorId = json['category_id'];
    documentId = json['document_id'];
    productName = json['product_name'];
    productDescription = json['product_description'];
    productPhoto = json['product_photo'];
    productPrice = json['product_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = productId;
    data['menu_id'] = productId;
    data['categorId'] = categorId;
    data['document_id'] = documentId;
    data['product_name'] = productName;
    data['product_description'] = productDescription;
    data['product_photo'] = productPhoto;
    data['product_price'] = productPrice;

    return data;
  }
}
