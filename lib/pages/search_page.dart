import 'package:chat_app/helper/helper_functions.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  User? user;
  bool isInGroup = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserNameAndId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFF393E46)),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Search",
          style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Color(0xFF393E46)),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Color(0xFF393E46)),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintStyle:
                          TextStyle(color: Color(0xFF393E46), fontSize: 17),
                      hintText: "Search for groups...",
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    startSearch();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF393E46).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(Icons.search, color: Color(0xFF393E46)),
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                )
              : showGroupList(),
        ],
      ),
      backgroundColor: const Color(0xFF393E46),
    );
  }

  String getUserName(String name) {
    return name.substring(name.indexOf("_") + 1);
  }

  startSearch() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DatabaseService()
          .searchGroupsByName(searchController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  showGroupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                userName,
                searchSnapshot!.docs[index]['groupId'],
                searchSnapshot!.docs[index]['groupName'],
                searchSnapshot!.docs[index]['admin'],
              );
            },
          )
        : Container();
  }

  joined(
      String userName, String groupId, String groupName, String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUserInGroup(groupName, groupId, userName)
        .then((value) {
      setState(() {
        isInGroup = value;
      });
    });
  }

  getCurrentUserNameAndId() async {
    await HelperFunctions.getUserNameSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    //Provjera da li je korisnik u grupi
    joined(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(
              fontWeight: FontWeight.w500, color: Color(0xFF393E46)),
        ),
      ),
      title: Text(groupName,
          style: const TextStyle(
              fontWeight: FontWeight.w500, color: Color(0xFFEEEEEE))),
      subtitle: Text("Admin: ${getUserName(admin)}",
          style: const TextStyle(color: Color(0xFFEEEEEE))),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid)
              .toggleGroupJoin(groupId, userName, groupName);
          if (isInGroup) {
            setState(() {
              isInGroup = !isInGroup;
            });
            showSnackBar(
                context, Colors.green, "Successfully joined the group");
            Future.delayed(const Duration(seconds: 0), () {
              nextScreen(
                  context,
                  ChatPage(
                    groupId: groupId,
                    groupName: groupName,
                    userName: userName,
                  ));
            });
          } else {
            setState(() {
              isInGroup = !isInGroup;
              showSnackBar(context, Colors.green,
                  "Successfully left the group $groupName");
            });
          }
        },
        child: isInGroup
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF222831),
                    border: Border.all(color: Colors.white)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Joined",
                  style: TextStyle(color: Colors.white),
                ))
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Join",
                  style: TextStyle(color: Color(0xFF393E46)),
                ),
              ),
      ),
    );
  }
}
