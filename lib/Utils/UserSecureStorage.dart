import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {

// Create storage
  static  final storage = new FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

// Unique key for token
  static  final _keyToken  = 'Token';
  static   final _keyTokenExpire  = 'TokenExpire';
  static  final _keyUsuario  = 'Usuario';



// Write token value
  static  Future<String?> setToken(tokenValue) async{
     await storage.write(key: _keyToken , value: tokenValue);
  }

  static  Future<String?> getToken() async{
    return  await storage.read(key: _keyToken );
  }


  static  Future<String?> setUsuario(usuarioValue) async{
    await storage.write(key: _keyUsuario , value:usuarioValue );
  }

  static  Future<String?> getUsuario() async{
    return await storage.read(key: _keyUsuario);
  }

  static Future<Map<String, String>> readAllData(String key) async {
    return await storage.readAll();
  }


}
