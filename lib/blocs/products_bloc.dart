import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class ProductBloc extends BlocBase{

    final _dataController = BehaviorSubject<Map>();
    final _loadingController = BehaviorSubject<bool>();
    final _createdController = BehaviorSubject<bool>();

    Stream<Map> get outData => _dataController.stream;
    Stream<bool> get outLoading => _loadingController.stream;
    Stream<bool> get outCreated => _createdController.stream;

   String categoryId;
   DocumentSnapshot product;


   Map<String, dynamic> unsavedData;


   ProductBloc({this.product, this.categoryId}){
      if(product != null){
        unsavedData = Map.of(product.data);
        unsavedData['Images'] = List.of(product.data['Images']);
        unsavedData['Sizes'] = List.of(product.data['Sizes']);

        _createdController.add(true);
      } else{
        unsavedData = {
          'Title': null,
          "Description": null,
          "Preço": null,
          'Images': [],
          "Sizes": []
        };

        _createdController.add(false);
      }

      _dataController.add(unsavedData);
   }

   void saveTitle(String title){
     unsavedData['Title'] = title;
   }
    void saveDescription(String description){
      unsavedData['Description'] = description;
    }
    void savePrice(String price){
      unsavedData['Preço'] = double.parse(price);
    }

    void saveSizes(List sizes){
     unsavedData['Sizes'] = sizes;
    }

    void saveImages(List images){
     unsavedData['Images'] = images;
    }
    
    Future<bool> saveProduct() async {
     _loadingController.add(true);
    try{
      if(product != null){
       await _uploadImages(product.documentID);
       await product.reference.updateData(unsavedData);
      } else{
       DocumentReference dr = await Firestore.instance.collection('products').document(categoryId)
            .collection('items').add(Map.from(unsavedData..remove('Images')));

       await _uploadImages(dr.documentID);
       await dr.updateData(unsavedData);
      }
      _createdController.add(false);
      _loadingController.add(false);
      return true;
    } catch(e){
      _loadingController.add(false);
      return false;
    }

    }

    Future _uploadImages(String productId) async {
     for(int i = 0; i < unsavedData['Images'].length; i++){
       if(unsavedData['Images'][i] is String) continue;

       StorageUploadTask uploadTask = FirebaseStorage.instance.ref().child(categoryId)
       .child(productId).child(DateTime.now().microsecondsSinceEpoch.toString()).putFile(unsavedData['Images'][i]);

       StorageTaskSnapshot s = await uploadTask.onComplete;
       String dowloadUrl = await s.ref.getDownloadURL();

       unsavedData['Images'][i] = dowloadUrl;
     }
    }

    void deleteProduct(){
     product.reference.delete();
    }

  @override
  void dispose() {
     _dataController.close();
     _loadingController.close();
     _createdController.close();
  }

}