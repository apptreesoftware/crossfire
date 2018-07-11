import 'package:json_annotation/json_annotation.dart';

part 'configuration.g.dart';

@JsonSerializable()
class FirebaseConfiguration extends Object
    with _$FirebaseConfigurationSerializerMixin {
  final String apiKey;
  final String authDomain;
  final String databaseUrl;
  final String projectId;
  final String storageBucket;
  final String iosGoogleAppId;
  final String androidGoogleAppId;
  final String iosGCMSenderId;

  FirebaseConfiguration({
    this.apiKey,
    this.authDomain,
    this.databaseUrl,
    this.projectId,
    this.storageBucket,
    this.androidGoogleAppId,
    this.iosGoogleAppId,
    this.iosGCMSenderId,
  });

  factory FirebaseConfiguration.fromJson(json) =>
      _$FirebaseConfigurationFromJson(json);
}
