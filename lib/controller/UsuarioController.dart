import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Usuario.dart';

class UsuarioController{

  UsuarioController();

  Usuario usuario = Usuario();

  Future<Null> obterUsuarioPorCPF(String cpf) async {
    CollectionReference ref = Firestore.instance.collection('usuarios');
    QuerySnapshot eventsQuery = await ref
    .where("cpf", isEqualTo: cpf)
    .getDocuments();

    eventsQuery.documents.forEach((document) {
    Usuario u = Usuario.buscarFirebase(document);
    usuario = u;
});
}
}