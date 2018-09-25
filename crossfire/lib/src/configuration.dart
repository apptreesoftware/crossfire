class FirebaseConfiguration {
  final String apiKey;
  final String authDomain;
  final String databaseUrl;
  final String projectId;
  final String storageBucket;
  final String iosGoogleAppId;
  final String androidGoogleAppId;
  final String messageSenderId;

  FirebaseConfiguration({
    this.apiKey,
    this.authDomain,
    this.databaseUrl,
    this.projectId,
    this.storageBucket,
    this.androidGoogleAppId,
    this.iosGoogleAppId,
    this.messageSenderId,
  });

  factory FirebaseConfiguration.fromJson(json) => new FirebaseConfiguration(
      apiKey: json['apiKey'] as String,
      authDomain: json['authDomain'] as String,
      databaseUrl: json['databaseUrl'] as String,
      projectId: json['projectId'] as String,
      storageBucket: json['storageBucket'] as String,
      androidGoogleAppId: json['androidGoogleAppId'] as String,
      iosGoogleAppId: json['iosGoogleAppId'] as String,
      messageSenderId: json['messageSenderId'] as String);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'apiKey': apiKey,
        'authDomain': authDomain,
        'databaseUrl': databaseUrl,
        'projectId': projectId,
        'storageBucket': storageBucket,
        'iosGoogleAppId': iosGoogleAppId,
        'androidGoogleAppId': androidGoogleAppId,
        'messageSenderId': messageSenderId
      };
}
