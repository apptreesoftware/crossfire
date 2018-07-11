# crossfire

Cross-platform APIs for Firebase.  

## Usage

Build your API using a `crossfire` `Firebase` object:

```dart
import 'package:crossfire/crossfire.dart';

class MyFancyApp {
  final Firebase _firebase;  
  MyFancyApp(this._firebase);
}
``` 

and build some API methods:

```dart
import 'package:crossfire/crossfire.dart';

class MyFancyApp {
  final Firebase _firebase;  
  MyFancyApp(this._firebase);
  
  Future saveData() async {
    var docRef = await _firebase.getDocument("path/to/doc");
    docRef.setData({"hello": "firebase"});
  }
}
``` 

Then inject the `Firebase` implementation based on the platform:

```dart
import 'package:crossfire/crossfire.dart';
import 'package:crossfire_web/crossfire_web.dart';

FirebaseConfiguration configuration;

Future setupMyApp() async {
  var firebase = new FirebaseWeb();
  await firebase.init(configuration);
  var app = new MyFancyApp();
}
```

```dart
import 'package:crossfire/crossfire.dart';
import 'package:crossfire_web/crossfire_flutter.dart';
FirebaseConfiguration configuration;

Future setupMyApp() async {
  var firebase = new FirebaseFlutter();
  await firebase.init(configuration);
  var app = new MyFancyApp();
}
```

note: a FirebaseConfiguration usually looks something like this:

```dart
FirebaseConfiguration configuration;
void setupConfig() {
  configuration = new FirebaseConfiguration(
    apiKey: "<API_KEY>",
    databaseUrl: "https://mydb.firebaseio.com",
    storageBucket: "myapp.appspot.com",
    projectId: "myproject",
    iosGoogleAppId: "1:111111111111:ios:22222222222222222",
    androidGoogleAppId: "1:111111111111:android:22222222222222222",
  );
}
```
