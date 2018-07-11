// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirebaseConfiguration _$FirebaseConfigurationFromJson(
    Map<String, dynamic> json) {
  return new FirebaseConfiguration(
      json['apiKey'] as String,
      json['authDomain'] as String,
      json['databaseUrl'] as String,
      json['projectId'] as String,
      json['storageBucket'] as String,
      json['androidGoogleAppId'] as String,
      json['iosGoogleAppId'] as String,
      json['iosGCMSenderId'] as String);
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
