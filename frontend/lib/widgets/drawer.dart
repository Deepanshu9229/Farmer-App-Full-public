import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:Container(
        // color: Color(0xff4FAD55),
      child: ListView(
        children: const [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              accountName: Text("Name of Farmer"),
              accountEmail: Text("kisaan@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage("assets/images/blabla.jpeg"),
              ),
            ),
          ),
          ListTile(
            leading: Icon(CupertinoIcons.home, color: Colors.black,),
            title: Text("Home" , style: TextStyle(color: Colors.black, fontWeight:FontWeight.bold),),
          ),
          ListTile(
            leading: Icon(CupertinoIcons.mail_solid, color: Colors.black,),
            title: Text("Contact" , style: TextStyle(color: Colors.black, fontWeight:FontWeight.bold),),
          ),
          ListTile(
            leading: Icon(CupertinoIcons.arrow_uturn_left_circle, color: Colors.black,),
            title: Text("Signout" , style: TextStyle(color: Colors.black, fontWeight:FontWeight.bold),),
          )
        ],
      ),
      ),
    );
  }
}
