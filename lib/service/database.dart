import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseMethod {
  Future addProductDetails(
      Map<String, dynamic> productInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("product")
        .doc(id)
        .set(productInfoMap);
  }
  Future<Stream<QuerySnapshot>> getProductDetails()async{
    return await FirebaseFirestore.instance.collection("product").snapshots();
  }
  Future updateProductDetails(String id,Map<String , dynamic> updateInfor)async{
    return await FirebaseFirestore.instance.collection("product").doc(id).update(updateInfor);
  }
  Future deleteProductDetails(String id)async{
    return await FirebaseFirestore.instance.collection("product").doc(id).delete();
  }
  
}
