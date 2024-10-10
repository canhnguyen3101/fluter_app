import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:universal_io/io.dart' as universal;
import 'package:image_picker/image_picker.dart';
import '../service/database.dart';

class Employee extends StatefulWidget {
  const Employee({super.key});

  @override
  State<Employee> createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController pricecontroller = new TextEditingController();

  String imageUrl='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Product",
                style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Text(" Form",
                style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold))
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20.0, top: 30.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Name",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.only(left: 5.0),
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: namecontroller,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "Price",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.only(left: 5.0),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: pricecontroller,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    ImagePicker imagePicker = ImagePicker();
                    XFile? file = await imagePicker.pickImage(source: ImageSource.camera);
                    if (file == null) return;
                    print('${file.path}');

                    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
                    Reference referenceRoot = FirebaseStorage.instance.ref();
                    Reference referenceDirImage = referenceRoot.child('images');
                    Reference referenceImageToUpload = referenceDirImage.child(uniqueFileName);

                    try {
                      // Đợi upload file và lấy URL
                      await referenceImageToUpload.putFile(File(file.path));
                      String downloadUrl = await referenceImageToUpload.getDownloadURL();

                      // Cập nhật imageUrl và hiển thị đường dẫn
                      setState(() {
                        imageUrl = downloadUrl;
                      });
                    } catch (error) {
                      print("Error uploading image: $error");
                    }
                  },
                  icon: Icon(Icons.camera_alt),
                ),
                SizedBox(width: 8), // Khoảng cách giữa icon và text
                Expanded(
                  child: Text(
                    imageUrl.isNotEmpty ? imageUrl : 'Chưa có hình ảnh',
                    overflow: TextOverflow.ellipsis, // Đoạn text không đủ chỗ sẽ bị cắt
                    maxLines: 1, // Giới hạn số dòng hiển thị
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),



            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Retrieve the name and age from the text controllers
                  String name = namecontroller.text.trim();
                  String priceString = pricecontroller.text.trim();

                  // Validation
                  if (name.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Name cannot be empty",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    return; // Exit the function if name is invalid
                  }

                  if (priceString.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Age cannot be empty",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    return; // Exit the function if age is invalid
                  }

                  // Try to parse age to an integer
                  int? price = int.tryParse(priceString);
                  if (price == null || price <= 0) {
                    Fluttertoast.showToast(
                      msg: "Please enter a valid price",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    return; // Exit the function if age is invalid
                  }

                  try {
                    String id = randomAlphaNumeric(10);
                    Map<String, dynamic> employeeInfoMap = {
                      "id": id,
                      "name": name,
                      "price": price,
                      "image": imageUrl ?? "",
                    };

                    print("Attempting to add product details: $employeeInfoMap");

                    await DatabaseMethod().addProductDetails(employeeInfoMap, id).then((value) {
                      print("Product added successfully");
                      Fluttertoast.showToast(
                        msg: "Upload success",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green, // Change to green for success
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    });
                  } catch (e) {
                    print("Error: $e"); // Log lỗi ra console để kiểm tra
                    Fluttertoast.showToast(
                      msg: "Upload failed: $e",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
                child: Text("Add Product"),
              ),
            )

          ],
        ),
      ),

    );
  }
}
