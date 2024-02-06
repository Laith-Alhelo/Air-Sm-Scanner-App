import 'package:Sea_Sm/views/screens/search_air_folders_page.dart';
import 'package:Sea_Sm/views/screens/search_sea_folders_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      color: Colors.white.withOpacity(.9),
      child: Column(
        children: [
          SizedBox(
            height: 200,
              child: Image.asset(
            'assets/images/drawerimg.jpg',
            fit: BoxFit.cover,
          )),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            title: Text(
              'Air Shipments',
              // ignore: deprecated_member_use
              style: TextStyle(fontSize: 19.sp),
            ),
            leading: const Icon(
              Icons.folder,
              color: Colors.red,
              size: 40,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchAirFoldersPage()),
              );
            },
          ),
          ListTile(
            title: Text(
              'Sea Shipments',
              // ignore: deprecated_member_use
              style: TextStyle(fontSize: 19.sp),
            ),
            leading: const Icon(
              Icons.folder,
              color: Colors.red,
              size: 40,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchSeaFoldersPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
