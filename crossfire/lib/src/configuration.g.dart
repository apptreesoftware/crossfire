// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirebaseConfiguration _$FirebaseConfigurationFromJson(
    Map<String, dynamic> json) {
  return new FirebaseConfiguration(
      apiKey: json['apiKey'] as String,
      authDomain: json['authDomain'] as String,
      databaseUrl: json['databaseUrl'] as String,
      projectId: json['projectId'] as String,
      storageBucket: json['storageBucket'] as String,
      androidGoogleAppId: json['androidGoogleAppId'] as String,
      iosGoogleAppId: json['iosGoogleAppId'] as String,
      iosGCMSenderId: json['iosGCMSenderId'] as String);
}

abstract class _$FirebaseConfigurationSerializerMixin {
  String get apiKey;
  String get authDomain;
  String get databaseUrl;
  String get projectId;
  String get storageBucket;
  String get iosGoogleAppId;
  String get androidGoogleAppId;
  String get iosGCMSenderId;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'apiKey': apiKey,
        'authDomain': authDomain,
        'databaseUrl': databaseUrl,
        'projectId': projectId,
        'storageBucket': storageBucket,
        'iosGoogleAppId': iosGoogleAppId,
        'androidGoogleAppId': androidGoogleAppId,
        'iosGCMSenderId': iosGCMSenderId
      };
}
