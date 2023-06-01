import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  //Reference na firebase kolekcije
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  //Spremanje podataka o korsniku
  Future saveUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "uid": uid,
    });
  }

  //Dobivanje podataka o korisniku
  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //Dobivanje grupa u kojima je korisnik
  getUserGroup() async {
    return userCollection.doc(uid).snapshots();
  }

  //Izrada grupe
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    //Azuriranje korisnika grupe
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userdocumentReference = userCollection.doc(uid);
    return await userdocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"]),
    });
  }

  //Dobivanje chatova
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot["admin"];
  }

  //Dobivanje clanova grupe
  getGroupMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  //Pretrazivanje grupa po imenu
  searchGroupsByName(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  Future<bool> isUserInGroup(
      String groupName, String groupId, String userName) async {
    DocumentReference uRef = userCollection.doc(uid);
    DocumentSnapshot dSnap = await uRef.get();

    List<dynamic> groups = await dSnap['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // Join / exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    DocumentReference uRef = userCollection.doc(uid);
    DocumentReference gRef = groupCollection.doc(groupId);

    DocumentSnapshot dSnap = await uRef.get();
    List<dynamic> groups = await dSnap['groups'];

    if (groups.contains("${groupId}_$groupName")) {
      //Izlazak iz grupe
      await uRef.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"]),
      });
      await gRef.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"]),
      });
    } else {
      //Ulazak u grupu
      await uRef.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"]),
      });
      await gRef.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      });
    }
  }

  //Slanje poruka
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData["message"],
      "recentMessageSender": chatMessageData["sender"],
    });
  }
}
