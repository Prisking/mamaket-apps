import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mamaket/constants/constants.dart';
import 'package:mamaket/ui/pages/products/controller/product_controller.dart';
import 'package:mamaket/ui/pages/products/widgets/geometry_check.dart';
import 'package:mamaket/ui/pages/products/widgets/selected_images.dart';
import 'package:mamaket/ui/pages/products/widgets/selected_tags.dart';
import 'package:provider/provider.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final _formKey = GlobalKey<FormState>();

  Box userData = Hive.box("userData");

  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController tags = TextEditingController();
  TextEditingController quantity = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context);
    final categories = productController.categories;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Upload Product"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            GeometryCheck(),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DropdownButtonFormField(
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      productController.setCategoryId(value);
                    },
                    items: categories.map(
                      (category) {
                        return DropdownMenuItem(
                          value: category.sId,
                          child: Text(category.name),
                        );
                      },
                    ).toList(),
                    decoration: InputDecoration(labelText: 'Category'),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: name,
                    decoration: InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your product title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    controller: description,
                    decoration: InputDecoration(
                      labelText: 'Description',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your product description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  DropdownButtonFormField(
                    onChanged: (value) {
                      productController.setProductSaleType(value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                    items: <DropdownMenuItem>[
                      DropdownMenuItem(
                        value: "wholesale",
                        child: Text("Wholesale"),
                      ),
                      DropdownMenuItem(
                        value: "retail",
                        child: Text("Retail"),
                      )
                    ],
                    decoration: InputDecoration(labelText: 'Type'),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: price,
                    decoration: InputDecoration(
                      labelText: 'Unit Price',
                      prefix: Text("₦ "),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your price';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: quantity,
                    decoration: InputDecoration(
                      labelText: 'Available Quantity',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  SelectedTags(),
                  TextFormField(
                    controller: tags,
                    decoration: InputDecoration(
                      labelText: 'Add Search Tags (eg. Food)',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          if (tags.text == "") {
                            return;
                          }
                          if (productController.tags.contains(tags.text)) {
                            //snackbar
                            return;
                          }
                          if (productController.tags.length == 10) {
                            return;
                          }
                          productController.addTag(tags.text);
                          tags.text = "";
                        },
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "Negotiable:",
                        style: TextStyle(color: kLightGrey),
                      ),
                      Switch(
                        activeColor: kPrimaryColor,
                        value: productController.negotiable,
                        onChanged: (value) {
                          productController.setNegotiable(value);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Add Pictures (max: 3)",
                    style: TextStyle(color: kLightGrey),
                  ),
                  SizedBox(height: 10),
                  SelectedImages(),
                  SizedBox(height: 30.0),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 250,
                      height: 45,
                      child: ValueListenableBuilder(
                        valueListenable: userData.listenable(),
                        builder: (context, box, _) => RaisedButton(
                          disabledColor: Colors.grey,
                          color: kPrimaryColor,
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              if (productController.selectedImages.length ==
                                  0) {
                                productController.showSnackbar("No Image",
                                    "Please select images to upload");
                                return;
                              } else if (box.get("user").geometry == null) {
                                productController.showSnackbar(
                                    "Update Profile", kGeometryCheck);
                              } else {
                                productController.createProduct(
                                  name.text,
                                  description.text,
                                  quantity.text,
                                  price.text,
                                );
                              }
                            }
                          },
                          child: productController.isDisabled
                              ? Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    backgroundColor: Colors.white,
                                  ),
                                )
                              : Text(
                                  "Upload",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
