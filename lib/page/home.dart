import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_app/page/employee.dart';
import 'package:my_app/service/database.dart';
import 'package:random_string/random_string.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}
const String defaultImageUrl = "https://t4.ftcdn.net/jpg/04/73/25/49/360_F_473254957_bxG9yf4ly7OBO5I0O5KABlN930GwaMQz.jpg";
String agee="";
class _HomeState extends State<Home> {
  Stream? EmployeeStream;
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController pricecontroller = new TextEditingController();
  getontheLoad() async {
    EmployeeStream = await DatabaseMethod().getProductDetails();
    setState(() {});
  }
  @override
  initState() {
    getontheLoad();
    super.initState();
  }
  Widget allEmployeeDetails() {
    return StreamBuilder(
        stream: EmployeeStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return Container(
                      margin:
                          EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),

                          ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  ds["image"].isEmpty ? defaultImageUrl : ds["image"], // Kiểm tra chuỗi rỗng
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Name: " + ds["name"],
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "Price: ${ds["price"]}",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10), // Khoảng cách bên phải của thông tin
                                // Nút chỉnh sửa và xóa
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        namecontroller.text = ds["name"];
                                        pricecontroller.text = ds["price"].toString();
                                        EditEmployeeDetails(ds["id"]);
                                      },
                                      child: Icon(Icons.edit, color: Colors.blueGrey),
                                    ),
                                    SizedBox(height: 5), // Khoảng cách giữa nút chỉnh sửa và xóa
                                    GestureDetector(
                                      onTap: () async {
                                        await DatabaseMethod().deleteProductDetails(ds["id"]);
                                      },
                                      child: Icon(Icons.delete, color: Colors.blueGrey),
                                    ),
                                  ],
                                ),
                              ],
                            )


                        ),
                      ),
                    );
                  })
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Employee()));
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ Text("Data",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
           ],
        ),
      ),
      body: Container(
        child: Column(
          children: [Expanded(child: allEmployeeDetails())],
        ),
      ),
    );
  }

  Future EditEmployeeDetails(String id) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.cancel),
                ),
                SizedBox(width: 50.0),
                Text("Edit", style: TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Details", style: TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(width: 20.0),
            Text("Name", style: TextStyle(color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.only(left: 5.0),
              decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: namecontroller,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            SizedBox(height: 10.0),
            Text("Price", style: TextStyle(color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.only(left: 5.0),
              decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: pricecontroller,
                decoration: InputDecoration(border: InputBorder.none),
                keyboardType: TextInputType.number, // Ensures only numbers can be inputted
              ),
            ),
            SizedBox(height: 50.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  String name = namecontroller.text.trim();
                  String priceString = pricecontroller.text.trim();

                  // Validation checks
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
                      msg: "price cannot be empty",
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

                  // Proceed with updating the employee details
                  Map<String, dynamic> updateInfor = {
                    "name": name,
                    "price": price, // Use the validated integer age
                  };
                  await DatabaseMethod().updateProductDetails(id, updateInfor).then((value) {
                    Navigator.pop(context);
                  });
                },
                child: Text("Update", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ),
  );

}
