import 'package:flutter/material.dart';

class showFullImage extends StatelessWidget {
  String imageUrl
  ;
  showFullImage({required this.imageUrl});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.network(imageUrl, fit: BoxFit.cover,)),
          Positioned(
            top: 30,
            left: 20,
            child: IconButton(
              onPressed: () =>Navigator.pop(context), 
              icon: const Icon(Icons.arrow_circle_left_rounded, color: Colors.white38, size: 45,),
              )),
        ],
      ),
    );
  }
}