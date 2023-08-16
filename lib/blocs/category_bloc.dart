import 'dart:async';
import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class CategoryBloc extends BlocBase{
  
  
  final _titleController = BehaviorSubject<String>();
  final _imageController = BehaviorSubject();
  final _deleteController = BehaviorSubject<bool>();

  Stream<String> get outTitle => _titleController.stream.transform(
    StreamTransformer<String, String>.fromHandlers(
      handleData: (title,sink){
        if(title.isEmpty)
        sink.addError('Insura um título');
        else
          sink.add(title);
      } 
    )
  );
  Stream get outImage => _imageController.stream;
  Stream<bool> get outDelete => _deleteController.stream;

  Stream<bool> get submitValid => Observable.combineLatest2(
    outTitle, outImage, (a,b) => true
  );
  
    DocumentSnapshot category;
    
    String title;
    File image;

    CategoryBloc(this.category){
      if(category != null){
        title = category.data['Title'];

        _titleController.add(category.data['Title']);
        _imageController.add(category.data['Icon']);
        _deleteController.add(true);
      } else {
        _deleteController.add(false);
      }
    }

    void setTitle(String title){
      this.title = title;
      _titleController.add(title);
    }

    void setImage(File file){
      image = file;
      _imageController.add(file);
    }

    Future saveData() async {
      if(image == null && category != null && title == category.data['Title']) return ;


      Map<String, dynamic> dataToUpdate = {};

      if(image != null){
        StorageUploadTask task = FirebaseStorage.instance.ref().child('icons')
        .child(title).putFile(image);

        StorageTaskSnapshot snap = await task.onComplete;
        dataToUpdate['Icon'] = await snap.ref.getDownloadURL();
      }

      if(category == null || title != category.data['Title']){
        dataToUpdate['Title'] = title;
      }

      if(category == null){
        await Firestore.instance.collection('products').document(title.toLowerCase())
        .setData(dataToUpdate);
      } else {
        await category.reference.updateData(dataToUpdate);
      }

    }

    void delete(){
      category.reference.delete();
    }

  @override
  void dispose() {
    _titleController.close();
    _imageController.close();
    _deleteController.close();
  }
}