import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/personalization/models/user_model.dart';
import '../../../utils/exceptions/supabase_auth_exceptions.dart';
import '../../repositories/authentication/authentication_repository.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class UserRepository extends GetxController {

  static UserRepository get instance => Get.find();

  final SupabaseClient _supabase = Supabase.instance.client;
  final _table = 'users';
  /// Sauvegarder un nouvel utilisateur
  Future<void> saveUserRecord(UserModel user) async {
    try {

      print('🔄 Sauvegarde utilisateur: ${user.toJson()}');

      // Utilisez .select() pour obtenir une réponse
      final response =
          await _supabase.from(_table).insert(user.toJson()).select().single();

      print('✅ Utilisateur sauvegardé: $response');
    } on PostgrestException catch (e) {
      print('❌ Erreur PostgREST: ${e.code} - ${e.message}');
      throw 'Erreur base de données: ${e.message}';
    } catch (e, stack) {
      print('❌ Erreur inattendue: $e');
      print('Stack: $stack');
      throw 'Erreur sauvegarde: $e';
    }
  }

  /// Récupérer les infos de l'utilisateur connecté
  Future<UserModel> fetchUserDetails() async {
    try {
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser == null) throw 'No authenticated user.';

      final response = await _supabase
          .from(_table)
          .select()
          .eq('id', authUser.id)
          .maybeSingle();
      print('fetchUserDetails response: $response');
      if (response == null) {
        return UserModel.empty();
      }
      return UserModel.fromJson({
        ...response,
        'id': authUser.id,
        'email': authUser.email,
      });
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message,
          statusCode: int.tryParse(e.statusCode ?? ''));
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e, stack) {
      print("❌ fetchUserDetails error: $e");
      print(stack);
      rethrow; // don’t replace the error message
    }
  }

  /// Mettre à jour un utilisateur
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      final response = await _supabase
          .from(_table)
          .update(updatedUser.toJson())
          .eq('id', updatedUser.id);

      if (response.isEmpty) throw 'Update failed.';
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message,
          statusCode: int.tryParse(e.statusCode ?? ''));
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (_) {
      throw 'Something went wrong. Please try again update';
    }
  }

  /// Mettre à jour un champ spécifique
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      print('🔄 updateSingleField: $json');

      final userId = AuthenticationRepository.instance.authUser?.id;
      if (userId == null) throw 'No authenticated user.';

      final response =
          await _supabase.from(_table).update(json).eq('id', userId).select();
      print('✅ Update response: $response');

      if (response.isEmpty) throw 'Update failed.';
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message,
          statusCode: int.tryParse(e.statusCode ?? ''));
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (_) {
      throw 'updaSomething went wrong. Please try again';
    }
  }

  /// Supprimer un utilisateur
  Future<void> removeUserRecord(String userId) async {
    try {
      final response = await _supabase.from(_table).delete().eq('id', userId);

      if (response.isEmpty) throw 'Delete failed.';
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message,
          statusCode: int.tryParse(e.statusCode ?? ''));
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (_) {
      throw 'Something went wrong. Please try again';
    }
  }
}
