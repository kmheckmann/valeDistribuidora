import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_2/model/Usuario.dart';

class UsuarioController {
  UsuarioController();

  Usuario usuario = Usuario();

//Obtem os dados do usuário utilizando o CPF deste
  Future<Usuario> obterUsuarioPorCPF(String cpf) async {
    Usuario u;
    if (cpf.contains(" - ")) {
      var array = cpf.split(" - ");
      cpf = array[1];
    }
    //Acessa a collection
    CollectionReference ref = Firestore.instance.collection('usuarios');
    //Obtem da collection o registro onde o CPF seja igual ao que foi passado por parametro
    QuerySnapshot eventsQuery =
        await ref.where("cpf", isEqualTo: cpf).getDocuments();

    //Só existirá um usuário para cada CPF,
    //então pega os dados desde usuário retornado da collection e atribui a uma variavel
    eventsQuery.documents.forEach((document) {
      u = Usuario.buscarFirebase(document);
      u.id = document.documentID;
    });
    return Future.value(u);
  }
}
