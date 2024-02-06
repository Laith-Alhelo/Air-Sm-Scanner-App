import 'dart:math';
import 'package:Sea_Sm/views/widgets/drawer.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageFolder {
  String folderName;
  List<File> images;
  ImageFolder(this.folderName, this.images);
}

class HomeScannerPage extends StatefulWidget {
  const HomeScannerPage({Key? key}) : super(key: key);

  @override
  State<HomeScannerPage> createState() => _HomeScannerPageState();
}

class _HomeScannerPageState extends State<HomeScannerPage> {
  int numbereOfImages = 0;
  bool _downloading = false;
  List<ImageFolder> imageFolders = [];
  var imagePicker = ImagePicker();
  bool _showButton = false;
  String? scanResult;
  bool _uploading = false;
  Color backColor = const Color(0xFF8B0000);
  List<BoxShadow> myShadowList = const [
    BoxShadow(
      blurRadius: 0,
      color: Colors.black12,
      spreadRadius: .3,
      // offset: Offset(.1, 0),
    ),
  ];

  Future<void> openCameraAndGetImage(String folderName) async {
    var imgPicked = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 20,
    );
    if (imgPicked != null) {
      File file = File(imgPicked.path);
      ImageFolder folder = imageFolders.firstWhere(
        (element) => element.folderName == folderName,
        orElse: () {
          ImageFolder newFolder = ImageFolder(folderName, []);
          imageFolders.add(newFolder);
          return newFolder;
        },
      );
      setState(() {
        folder.images.add(file);
        numbereOfImages++;
        _showButton = true;
      });
      await openCameraAndGetImage(folderName); // Open camera again
    } else {
      print('no image picked');
    }
  }

  Future<void> uploadImageFolders(BuildContext context) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    int folderindex = imageFolders.length;
    int folderNum = 1;
    setState(() {
      _downloading = true;
    });
    try {
      for (ImageFolder folder in imageFolders) {
        folder.images.asMap().forEach((index, image) async {
          Random random = Random(10000);
          final Reference ref;
          if (scanResult?.length == 5) {
            ref = storage.ref().child('Sea SM').child(folder.folderName);
          } else {
            ref = storage.ref().child('Air SM').child(folder.folderName);
          }
          // else{
          //   continue;
          // }
          // String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          String imageName = 'image_ - ${DateTime.now()}.jpg';

          UploadTask task = ref.child(imageName).putFile(image);
          numbereOfImages--;
          print('number of images $numbereOfImages (inside nested for loob)');

          await task;
          print('Uploaded $index out of ${folder.images.length}');

          if (folder.images.length - index == 1) {
            setState(() {
              print('uploading to false:');
              _downloading = false;
              showUploadCompleteSnackbar(folderNum++);
            });
          }
          folder.images.removeAt(index);

          // // Remove the uploaded image from the list
          // setState(() {
          //   folder.images.removeAt(index);
          //   if(folder.images.isEmpty){
          //     print('folder.images.length: ${folder.images.length}');
          //     imageFolders.remove(folder);
          //   }
          //   if (imageFolders.isEmpty) {
          //     _downloading = false;
          //   }
          // });
        });

        // yRemove the uploaded image from the list
        print('Upload completed for ${folder.folderName}');
        folderindex--;
        print('Indexzxxxxxxx $folderindex');
      }

      print('Out side for loop');

      setState(() {
        _showButton = false;
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> barcodeScannerShow() async {
    String scanResult;
    try {
      scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'cancel',
        true,
        ScanMode.BARCODE,
      );
    } on Exception catch (e) {
      print('scanner error $e');
      scanResult = 'failed to get the barcode: $e';
    }
    if (!mounted) {
      setState(() {});
      return;
    }
    await openCameraAndGetImage(scanResult);
    // if ((scanResult.contains('-1')) ||
    //     (scanResult.length != 7 && scanResult.length != 5)) return;
    // if ((scanResult.length != 5) && (scanResult.length != 7)) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: const Center(child: Text('wrong parcode')),
    //       duration: const Duration(seconds: 3),
    //       margin: EdgeInsets.only(bottom: 70.h),
    //     ),
    //   );
    //   return;
    // }

    // final player = AudioPlayer();
    // player.play(AssetSource('audio/store-scanner-beep-90395.mp3'));
    // setState(() {
    //   this.scanResult = scanResult;
    // });
    // if (!scanResult.contains('-1') && scanResult.length == 5) {
    //   await openCameraAndGetImage(scanResult);
    // }
    // if (!scanResult.contains('-1') && scanResult.length == 7) {
    //   await openCameraAndGetImage(scanResult);
    // }
  } // end barcode function

  void showUploadCompleteSnackbar(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text('Folder $index has been uploaded.')),
        duration: Duration(seconds: 2),
      ),
    );
  }

  int getUploadingTime() {
    double uploadingTime = (numbereOfImages * 3.5) / 60;
    return uploadingTime.floor();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(
        drawer: MyDrawer(),
        appBar: _showButton == false
            ? AppBar(
                backgroundColor: backColor,
                title: const Text(
                  'Photo SM',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  if (_downloading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          if (getUploadingTime() > 1)
                            Text(
                              'uploading may take ${getUploadingTime()}min',
                            ),
                          if (getUploadingTime() < 1)
                            const Text(
                              'uploading may take few sec',
                            ),
                          const CircularProgressIndicator(
                            color: Colors.yellow,
                          ),
                        ],
                      ),
                    ),
                ],
              )
            : null,
        body: Stack(
          children: [
            homeUi(),
            if (_showButton) showMultibleFolders(),
          ],
        ),
      ),
    );
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure you want to go back?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  Widget showMultibleFolders() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: imageFolders.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(.8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'SMNO: ${imageFolders[index].folderName}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (imageFolders.length == 1) {
                                    setState(() {
                                      _showButton = false;
                                      _uploading = false;
                                      imageFolders.clear();
                                    });
                                  } else if (imageFolders.length > 1) {
                                    setState(() {
                                      imageFolders.remove(imageFolders[index]);
                                      numbereOfImages -=
                                          imageFolders[index].images.length;
                                      print(
                                          'number of images: $numbereOfImages');
                                    });
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    color: backColor.withOpacity(.5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Wrap(
                          children: imageFolders[index]
                              .images
                              .map(
                                (image) => Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  width: 100,
                                  height: 100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(image),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ///////
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Colors.yellow,
                    ),
                    child: MaterialButton(
                      onPressed: () async {
                        await uploadImageFolders(context);
                        print('finish uploading()((((()))))');
                      },
                      child: Text(
                        'Upload Folders',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Colors.black87,
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        barcodeScannerShow();
                      },
                      child: Text(
                        'Add Folder',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          _showButton = false;
                          _uploading = false;
                          imageFolders.clear();
                        });
                      },
                      child: const Icon(
                        Icons.redo,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget homeUi() {
    return Container(
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
                    child: Image.asset('assets/images/logo.jpeg'),
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Photo SM',
                              style: TextStyle(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Photo For Sea & Air Shipment',
                              style: TextStyle(
                                fontSize: 16.sp,
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
                            borderRadius: BorderRadius.circular(100.sp),
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
    );
  }
}
