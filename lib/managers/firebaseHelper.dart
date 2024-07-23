import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add a new document to a Firestore collection
  Future<void> addDocument(
      String collectionName, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).doc(data['name']).set(data);
    } catch (e) {
      print("Error adding document: $e");
      throw e;
    }
  }

  Future<void> addDoc(
      String collectionName, Map<String, dynamic> data, String docID) async {
    try {
      await _firestore.collection(collectionName).doc(docID).set(data);
    } catch (e) {
      print("Error adding document: $e");
      throw e;
    }
  }

  // Function to get a single document from a Firestore collection
  Future<Object?> getDocument(String collectionName, String documentId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection(collectionName).doc(documentId).get();
      return documentSnapshot.data();
    } catch (e) {
      print("Error getting document: $e");
      throw e;
    }
  }

  // Function to update a document in a Firestore collection
  Future<void> updateDocument(String collectionName, String documentId,
      Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).doc(documentId).update(data);
    } catch (e) {
      print("Error updating document: $e");
      throw e;
    }
  }

  Future<List<DocumentSnapshot>> getDocumentsInSubcollection(
      String collectionName,
      String documentId,
      String subcollectionName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .doc(documentId)
          .collection(subcollectionName)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print("Error getting documents from subcollection: $e");
      throw e;
    }
  }

  Future<dynamic> getFieldInSubcollection(
    String collectionName,
    String documentId,
    String subcollectionName,
    String subdocumentId,
    String fieldName,
  ) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await FirebaseFirestore.instance
              .collection(collectionName)
              .doc(documentId)
              .collection(subcollectionName)
              .doc(subdocumentId)
              .get();

      // Check if the document exists
      if (!docSnapshot.exists) {
        throw Exception('Document does not exist');
      }

      // Extract the value of the specified field
      dynamic fieldValue = docSnapshot.data()?[fieldName];

      return fieldValue;
    } catch (e) {
      print("Error getting field from subcollection document: $e");
      rethrow;
    }
  }

  Future<List<String>> getJobsInSubcollection(String collectionName,
      String documentId, String subcollectionName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .doc(documentId)
          .collection(subcollectionName)
          .get();

      List<String> jobList = [];

      querySnapshot.docs.forEach((doc) {
        String job = doc['job'];
        jobList.add(job);
      });

      return jobList;
    } catch (e) {
      print("Error getting jobs from subcollection: $e");
      throw e;
    }
  }

  Future<List<String>> getObjectId(String collectionName, String documentId,
      String subcollectionName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .doc(documentId)
          .collection(subcollectionName)
          .get();

      List<String> object_ids = [];

      querySnapshot.docs.forEach((doc) {
        String job = doc['object_id'];
        object_ids.add(job);
      });

      return object_ids;
    } catch (e) {
      print("Error getting jobs from subcollection: $e");
      rethrow;
    }
  }

  Future<void> updateDocumentInCollection(
      String collectionName,
      String documentId,
      String subcollectionName,
      String subdocumentId,
      Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(documentId)
          .collection(subcollectionName)
          .doc(subdocumentId == "" ? null : subdocumentId)
          .set(data);
    } catch (e) {
      print("Error updating document in subcollection: $e");
      rethrow;
    }
  }

  // Function to delete a document from a Firestore collection
  Future<void> deleteDocument(String collectionName, String documentId) async {
    try {
      await _firestore.collection(collectionName).doc(documentId).delete();
    } catch (e) {
      print("Error deleting document: $e");
      rethrow;
    }
  }

  // Function to get all documents from a Firestore collection
  Future<List<Map<String, dynamic>>> getAllDocuments(
      String collectionName) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collectionName).get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error getting all documents: $e");
      rethrow;
    }
  }

  // New function to fetch jobs from Firestore
  Future<List<String>> fetchJobs() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('الوظائف').get();
      List<String> jobs = querySnapshot.docs.map((doc) => doc.id).toList();
      return jobs;
    } catch (e) {
      print("Error fetching jobs: $e");
      throw e;
    }
  }

  // New function to fetch departments from Firestore
  Future<List<String>> fetchDepartments() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('إدارات').get();
      List<String> departments =
          querySnapshot.docs.map((doc) => doc.id).toList();
      return departments;
    } catch (e) {
      print("Error fetching departments: $e");
      throw e;
    }
  }

  // New function to fetch locations from Firestore
  Future<List<String>> fetchLocations() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('ألمواقع').get();
      List<String> locations = querySnapshot.docs.map((doc) => doc.id).toList();
      return locations;
    } catch (e) {
      print("Error fetching locations: $e");
      throw e;
    }
  }

  // New function to fetch projects from Firestore based on selected department
  Future<List<String>> fetchProjects(String departmentId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('إدارات')
          .doc(departmentId)
          .collection('مشاريع')
          .get();

      List<String> projects =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      return projects;
    } catch (e) {
      print("Error fetching projects: $e");
      throw e;
    }
  }
}
