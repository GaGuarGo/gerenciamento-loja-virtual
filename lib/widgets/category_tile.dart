import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerenciamento_loja/screens/products_screen.dart';
import 'package:gerenciamento_loja/widgets/edit_category_dialog.dart';

class CategoryTile extends StatelessWidget {
  final DocumentSnapshot category;

  CategoryTile(this.category);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ExpansionTile(
          leading: GestureDetector(
            onTap: (){
              showDialog(context: context, builder: (context) => EditCategoryDialog(
                category: category,
              ));
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(category.data['Icon']),
              backgroundColor: Colors.transparent,
            ),
          ),
          title: Text(
            category.data['Title'],
            style:
                TextStyle(color: Colors.grey[850], fontWeight: FontWeight.w500),
          ),
          children: [
            FutureBuilder<QuerySnapshot>(
              future: category.reference.collection('items').getDocuments(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Container();
                else
                  return Column(
                      children: snapshot.data.documents.map((doc) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(doc.data['Images'][0]),
                      ),
                      title: Text(doc.data['Title']),
                      trailing:
                          Text("R\$${doc.data['Preço'].toStringAsFixed(2)}"),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProductScreen(
                                  categoryId: category.documentID,
                                  product: doc,
                                )));
                      },
                    );
                  }).toList()
                        ..add(ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Icon(Icons.add, color: Colors.pinkAccent),
                          ),
                          title: Text("Adicionar"),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProductScreen(
                                      categoryId: category.documentID,
                                    )));
                          },
                        )));
              },
            )
          ],
        ),
      ),
    );
  }
}
