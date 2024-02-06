import 'package:Sea_Sm/views/screens/show_full_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class SearchSeaFoldersPage extends StatefulWidget {
  SearchSeaFoldersPage({super.key});

  @override
  State<SearchSeaFoldersPage> createState() => _SearchSeaFoldersPageState();
}// Air SM

class _SearchSeaFoldersPageState extends State<SearchSeaFoldersPage> {
  Color backColor = const Color(0xFF8B0000);
  late Future<ListResult> futureFiles;
  bool beforeAnySearch = true;
  List allFoldersName = [];
  List filteredFolders = [];
  bool viewFilteredFoldersName = false;
  bool searched = false;
  TextEditingController _folderNameController = TextEditingController();

  String seafolderFiles = '';

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
      scanResult = 'failed to get the barcode: $e';
    }
    if (!mounted) {
      return ;
    }
    if ((scanResult.contains('-1')) ||
        (scanResult.length != 7 && scanResult.length != 5)) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Center(child: Text('try take parcode again')),
      //     duration: const Duration(seconds: 3),
      //     margin: EdgeInsets.only(bottom: 70.h),
      //   ),
      // );

      return;
    }
    if ((scanResult.length != 5) && (scanResult.length != 7)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Center(child: Text('wrong parcode')),
          duration: const Duration(seconds: 3),
          margin: EdgeInsets.only(bottom: 70.h),
        ),
      );
      return;
    }

    final player = AudioPlayer();
    player.play(AssetSource('audio/store-scanner-beep-90395.mp3'));
    beforeAnySearch = false;
    viewFilteredFoldersName = false;
    searched = true;
    seafolderFiles = scanResult;
    _folderNameController.clear;
    FocusScope.of(context).unfocus();
    futureFiles = FirebaseStorage.instance.ref('/Sea SM/$scanResult').listAll();
    setState(() {});
    
  } // end barcode function

  @override
  void initState() {
    fetchFolderNames();
    print('success');
    super.initState();
  }

  void fetchFolderNames() async {
    // Retrieve folder names from Firebase Storage
    Reference storageReference =
        FirebaseStorage.instance.ref().child('/Sea SM/');
    ListResult result = await storageReference.listAll();

    setState(() {
      allFoldersName = result.prefixes.map((folder) => folder.name).toList();
      filteredFolders = allFoldersName;
    });
  }

  void filterFolders(String query) {
    setState(() {
      filteredFolders = allFoldersName
          .where((folderName) => folderName.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backColor,
        title: const Text('sea shipments search'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
                onPressed: () {
                  barcodeScannerShow();
                },
                icon: const Icon(
                  Icons.barcode_reader,
                  size: 30,
                  color: Colors.black87,
                )),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _folderNameController,
              onChanged: (value) {
                if (searched) {
                  searched = false;
                }
                if (value.isNotEmpty) {
                  viewFilteredFoldersName = true;
                  filterFolders(value);
                } else {
                  filteredFolders.clear();
                  viewFilteredFoldersName = false;
                  setState(() {});
                }
              },
              onSubmitted: (value) {
                if (_folderNameController.text.isNotEmpty) {
                  beforeAnySearch = false;
                  viewFilteredFoldersName = false;
                  searched = true;
                  seafolderFiles = value;
                  _folderNameController.clear;
                  FocusScope.of(context).unfocus();
                  futureFiles =
                      FirebaseStorage.instance.ref('/Sea SM/$value').listAll();
                  setState(() {});
                }
              },
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    if (viewFilteredFoldersName) {
                      viewFilteredFoldersName = false;
                      _folderNameController.clear;
                      FocusScope.of(context).unfocus();
                      setState(() {});
                    }
                  },
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.black,
                  ),
                ),
                labelText: 'Enter Folder Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          if (viewFilteredFoldersName)
            Container(
              color: backColor.withOpacity(.5),
              height: 300,
              child: ListView.builder(
                  itemCount: filteredFolders.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          if (_folderNameController.text.isNotEmpty) {
                            viewFilteredFoldersName = false;
                            beforeAnySearch = false;
                            searched = true;
                            seafolderFiles = filteredFolders[index];
                            _folderNameController.clear;
                            FocusScope.of(context).unfocus();
                            futureFiles = FirebaseStorage.instance
                                .ref('/Sea SM/${filteredFolders[index]}')
                                .listAll();
                          }
                          setState(() {});
                        },
                        // ignore: deprecated_member_use
                        child: Text(
                          filteredFolders[index],
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                    );
                  }),
            ),
          if (searched && seafolderFiles.isNotEmpty && filteredFolders.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'The folder $seafolderFiles is not exist',
                  style: TextStyle(
                    fontSize: 25.sp,
                  ),
                ),
              ),
            ),
          if (seafolderFiles.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 20,
                ),
                Text(
                  seafolderFiles,
                  style: const TextStyle(
                    fontSize: 30,
                  ),
                ),
              ],
            ),
          seafolderFiles.isNotEmpty
              ? Expanded(
                  // flex: 5,
                  child: FutureBuilder(
                    future: futureFiles,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final files = snapshot.data!.items;
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 0.0,
                            mainAxisSpacing: 0.0,
                          ),
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            final file = files[index];
                            return FutureBuilder(
                              future: getImageURL(seafolderFiles,
                                  file.name), // Pass folder name and file name
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  String imageUrl = snapshot.data as String;
                                  var downloadIcon = Icons.download;
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Stack(
                                      children: [
                                        Container(
                                          color: Colors.black87,
                                          width: 50.w,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        showFullImage(
                                                          imageUrl: imageUrl,
                                                        )),
                                              );
                                            },
                                            child: Image.network(
                                              imageUrl, // Use the retrieved URL here
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          child: Container(
                                            width: 50.w,
                                            height: 70,
                                            color: Colors.black45,
                                            child: IconButton(
                                              onPressed: () {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'downloading..')),
                                                );
                                                downloadFile(file);
                                              },
                                              icon: const Icon(
                                                Icons.download,
                                                size: 30,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text('there is error occured'),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Future<String> getImageURL(String folderName, String fileName) async {
    try {
      Reference storageRef =
          FirebaseStorage.instance.ref('/Sea SM/$folderName/$fileName');
      String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error getting download URL: $e');
      return ''; // Return empty string or handle the error accordingly
    }
  }

  void downloadFile(Reference ref) async {
    final url = await ref.getDownloadURL();
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/${ref.name}';
    await Dio().download(url, path);

    await GallerySaver.saveImage(path, toDcim: true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('download completed')),
    );
  }
}
