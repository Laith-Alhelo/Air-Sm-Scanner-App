import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class HomeScannerPage extends StatefulWidget {
  const HomeScannerPage({super.key});

  @override
  State<HomeScannerPage> createState() => _HomeScannerPageState();
}

class _HomeScannerPageState extends State<HomeScannerPage> {
  String? scanResult;
  bool savedButtonPressed = false;
  File? file = File('');
  var imagePicker = ImagePicker();
  List<File> images = [];
  bool _showButton = false;
  Color backColor = const Color(0xFF8B0000);
  List<BoxShadow> myShadowList = const [
    BoxShadow(
      blurRadius: 0,
      color: Colors.black12,
      spreadRadius: .3,
      // offset: Offset(.1, 0),
    ),
  ];

  // open image camera
  Future openCameraAndGetImage() async {
    var imgPicked = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 1,
    );
    if (imgPicked != null) {
      file = File(imgPicked.path);
      var nameImg =
          basename(imgPicked.path); // take the image name without path
      setState(() {
        images.add(file!);
        _showButton = true;
      });
    } else {
      print('no image picked');
    }
  }

  Future<void> barcodeScannerShow() async {
    String scanResult;
    savedButtonPressed = false;
    try {
      scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'cancel',
        true,
        ScanMode.BARCODE,
      );
    } on PlatformException {
      scanResult = 'failed to get the barcode';
    }
    if (!mounted) {
      _showButton = false;
      setState(() {});
      return;
    };
    setState(() {
      this.scanResult = scanResult;
    });
    // open camera
    // if(scanResult.length==7){
    //   await openCameraAndGetImage();
    // }
    await openCameraAndGetImage();
    // else{
    //   barcodeScannerShow();
    // }
    // if (!scanResult.contains('-1') && scanResult.length != 2) {
    //   await openCameraAndGetImage();
    // } else {
    //   return;
    // }
  }

  /// upload to firebase:
  Future<void> uploadImg(List<File> images) async {
    final ref = FirebaseStorage.instance
        .ref('$scanResult');
        print('folder created');
    for (int i = 0; i < images.length; i++) {
      var random = Random().nextInt(10000000);
      String imgName =
          'image_${random}.jpeg'; // Adjust this naming scheme as needed
      try {
        await ref.child(imgName).putFile(images[i]);
        print('File uploaded to $scanResult folder');
      } catch (e) {
        print('Error uploading file: $e');
        return;
      }
    }
    images.clear();
    await barcodeScannerShow(); // Open barcode scanner after upload
  }

// var urlFile = ref.getDownloadURL();
  // print('file uploaded');
  // print(urlFile);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showButton == false
          ? AppBar(
              backgroundColor: backColor,
              elevation: 0,
              title: const Text(
                'Air SM',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              iconTheme: const IconThemeData(
                color: Colors.black,
                size: 30,
              ),
            )
          : null,
      body: Stack(
        children: [
          Container(
                  color: backColor,
                  height: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              boxShadow: myShadowList,
                            ),
                            child: SizedBox(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset('images/logo.jpeg'),
                                ),
                            ),
                          ),
                        ),
                        //      gradient:
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.red.withOpacity(.4),
                                      Colors.red,
                                    ],
                                  )),
                            ),
                            Container(
                              height: 38.h,
                              margin: const EdgeInsets.only(
                                top: 30,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: myShadowList,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Air SM',
                                          style: TextStyle(
                                            fontSize: 27.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Photo For Air Shipment',
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 70,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.yellow.withOpacity(.7),
                                        borderRadius:
                                            BorderRadius.circular(100.sp),
                                      ),
                                      child: MaterialButton(
                                        onPressed: () {
                                          barcodeScannerShow();
                                        },
                                        child: Text(
                                          'Add Photo',
                                          style: TextStyle(
                                            fontSize: 28.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              
          if (_showButton && images.length == 1) showFirstImage(),
          if (_showButton && images.length > 1) showMultiImages(),
        ],
      ),
      drawer: const Drawer(),
    );
  }

  Widget showFirstImage() {
    return Stack(
      children: [
        SizedBox(
          width: 100.w,
          height: double.infinity,
          child: Image.file(
            images[images.length - 1],
            fit: BoxFit.cover,
          ),
        ),
        // save button

        Positioned(
          bottom: 30,
          child: saveAndAddImageButtons(),
        ),
        Positioned(
          left: 30,
          top: 70,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.white),
              color: Colors.black38,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(11.0),
                child: Text(
                  scanResult ?? '',
                  style: TextStyle(
                    fontSize: 17.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget showMultiImages() {
    return Container(
      height: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            height: 70,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  Text(
                    '$scanResult',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 23.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black87,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: GridView.builder(
                itemCount: images.length, // Set the number of items in the grid
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns in the grid
                  crossAxisSpacing: 10.0, // Spacing between columns
                  mainAxisSpacing: 10.0, // Spacing between rows
                ),
                itemBuilder: (BuildContext context, int index) {
                  // Use this builder to create each grid item
                  return SizedBox(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          images[index],
                          fit: BoxFit.cover,
                        )),
                  );
                },
              ),
            ),
          ),
          saveAndAddImageButtons(),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget saveAndAddImageButtons() {
    return Container(
      width: 100.w,
      decoration: const BoxDecoration(
        color: Colors.black38,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(100),
            ),
            child: MaterialButton(
              onPressed: () async {
                await openCameraAndGetImage();
              },
              child: const Icon(
                Icons.add_photo_alternate,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          Container(
            width: 30.w,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.6),
              borderRadius: BorderRadius.circular(100),
            ),
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  _showButton = false;
                  images.clear();
                });
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontSize: 18.sp),
              ),
            ),
          ),
          Container(
            height: 50,
            width: 30.w,
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(.6),
              borderRadius: BorderRadius.circular(100),
            ),
            child: MaterialButton(
              onPressed: () async {
                // save to firebase
                if(savedButtonPressed==false){
                  if (file != null) {
                    setState(() {
                      savedButtonPressed = true;
                      // images.clear();
                    });
                    await uploadImg(images);
                    // setState(() {
                    //   _showButton = false;
                    // });
                  } else {
                    print('add image file');
                  }
                }
                // await barcodeScannerShow();
              },
              child: savedButtonPressed
                  ? const SizedBox(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.red,),
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
