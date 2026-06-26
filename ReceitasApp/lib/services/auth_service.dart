import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Serviço de autenticacao com Firebase.
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService() {
    _auth.authStateChanges().listen((_) => notifyListeners());
  }

  /// Usuario atualmente autenticado.
  User? get usuarioAtual => _auth.currentUser;

  /// Fluxo de mudancas de autenticacao.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Realiza login com e-mail e senha.
  Future<void> signIn(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
    } on FirebaseAuthException catch (e) {
      throw _traduzirErro(e.code);
    }
  }

  /// Registra um novo usuario e cria documento no Firestore.
  Future<void> signUp(String nome, String email, String senha) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      final usuario = credencial.user;
      if (usuario == null) {
        throw 'Nao foi possivel criar o usuario.';
      }

      await usuario.updateDisplayName(nome);
      await _firestore.collection('usuarios').doc(usuario.uid).set({
        'nome': nome,
        'email': email,
        'dataCadastro': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw _traduzirErro(e.code);
    }
  }

  /// Finaliza a sessao do usuario.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _traduzirErro(String codigo) {
    switch (codigo) {
      case 'invalid-email':
        return 'E-mail invalido.';
      case 'user-not-found':
        return 'Usuario nao encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'E-mail ja cadastrado.';
      case 'weak-password':
        return 'Senha fraca. Use pelo menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'Operacao nao permitida.';
      case 'network-request-failed':
        return 'Falha de rede. Verifique sua conexao.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro de autenticacao. Tente novamente.';
    }
  }
}
