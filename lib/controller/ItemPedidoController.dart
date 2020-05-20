import 'package:cloud_firestore/cloud_firestore.dart';

class ItemPedidoController{
  ItemPedidoController();

  String proxID;

  Future<Null> obterProxID(String idPedido) async{
    int idTemp = 0;
    int docID;
    CollectionReference ref = Firestore.instance.collection("pedidos").document(idPedido).collection("itens");
    QuerySnapshot eventsQuery = await ref.getDocuments();

    eventsQuery.documents.forEach((document){
      docID = int.parse(document.documentID);
      if(eventsQuery.documents.length == 0){
        idTemp = 1;
        proxID = idTemp.toString();
      }else{
        if(docID > idTemp){
          idTemp = docID;
        }
      }
    });

    idTemp = idTemp+1;
    proxID = idTemp.toString();
  }
}