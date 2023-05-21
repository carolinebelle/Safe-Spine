import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safespine/services/auth.dart';
import 'package:safespine/services/models.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:safespine/services/shared_preferences_provider.dart';

enum Collection {
  hospitals(path: "hospitals"),
  questions(path: "questions"),
  forms(path: "forms"),
  users(path: "users"),
  formTypes(path: "form_types");

  const Collection({
    required this.path,
  });

  final String path;

  CollectionReference<Map<String, dynamic>> ref(FirebaseFirestore db) =>
      db.collection(path);
}

class FirestoreService {
  static FirestoreService? _instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Source CACHE = Source.cache;
  final Source SERVER = Source.server;
  final SharedPreferencesProvider _sharedPreferencesProvider;

  static Future<FirestoreService> getInstance() async {
    if (_instance == null) {
      final provider = await SharedPreferencesProvider.getInstance();
      _instance = FirestoreService._(provider);
    }
    return _instance!;
  }

  FirestoreService._(SharedPreferencesProvider provider)
      : _sharedPreferencesProvider = provider;

  Timestamp? _getLastSync() {
    return _sharedPreferencesProvider.getSyncDate();
  }

  void _setLastSync(Timestamp timestamp) {
    _sharedPreferencesProvider.setSyncDate(timestamp);
  }

  Form _formFromFirebase(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data();
    return Form(
        id: doc.id,
        answers: Map<String, String>.from(data["answers"]),
        dateCompleted: data["dateCompleted"] as Timestamp?,
        dateStarted: data["dateStarted"] as Timestamp?,
        dateReceived: data["dateReceived"] as Timestamp?,
        form_type: data["form_type"] as String? ?? "",
        hospital: data["hospital"] as String? ?? "",
        title: data["title"] as String? ?? "",
        user: data["user"] as String? ?? "");
  }

  void _addField(DocumentReference<Map<String, dynamic>> docRef,
      String fieldName, dynamic fieldValue) {
    var data = {fieldName: fieldValue};

    docRef.set(data, SetOptions(merge: true));
  }

  // void addLastModifiedFieldNow() async {
  //   final now = Timestamp.now();

  //   void addLastModified(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  //     _addField(doc.reference, "lastModified", now);
  //   }

  //   final questionsRef = Collection.questions.ref(_db);
  //   final questionsSnapshot = await questionsRef.get();
  //   for (final doc in questionsSnapshot.docs) {
  //     addLastModified(doc);
  //   }

  //   final hospitalsRef = Collection.hospitals.ref(_db);
  //   final hospitalsSnapshot = await hospitalsRef.get();
  //   for (final doc in hospitalsSnapshot.docs) {
  //     addLastModified(doc);
  //   }

  //   final formatRef = Collection.formTypes.ref(_db);
  //   final formatSnapshot = await formatRef.get();

  //   for (final doc in formatSnapshot.docs) {
  //     final sectionRef = doc.reference.collection("Sections");
  //     final sectionSnapshot = await sectionRef.get();

  //     for (final sectionDoc in sectionSnapshot.docs) {
  //       addLastModified(sectionDoc);
  //     }
  //     addLastModified(doc);
  //   }

  //   _setLastSync(now);
  // }

  Query<Map<String, dynamic>> filterByModified(
      CollectionReference<Map<String, dynamic>> ref) {
    final Timestamp lastSync = _sharedPreferencesProvider.getSyncDate();
    return ref.where("lastModified", isGreaterThan: lastSync);
  }

  Future<List<FormType>> getFormTypes({bool fromCache = true}) async {
    final ref = Collection.formTypes.ref(_db);
    final query = fromCache ? ref : filterByModified(ref);
    final snapshot =
        await query.get(GetOptions(source: fromCache ? CACHE : SERVER));
    var formTypes = snapshot.docs.map((s) => FormType.fromJson(s.id, s.data()));
    return formTypes.toList();
  }

  Future<List<Section>> getSections(formType, {bool fromCache = true}) async {
    var ref = _db.collection('form_types/$formType/Sections');
    final query = fromCache ? ref : filterByModified(ref);
    final snapshot =
        await query.get(GetOptions(source: fromCache ? CACHE : SERVER));
    var sections = snapshot.docs.map((s) => Section.fromJson(s.id, s.data()));
    return sections.toList();
  }

  Future<List<Question>> getQuestions({bool fromCache = true}) async {
    var ref = Collection.questions.ref(_db);

    final query = fromCache ? ref : filterByModified(ref);
    final snapshot =
        await query.get(GetOptions(source: fromCache ? CACHE : SERVER));

    Iterable<Question> questions = snapshot.docs.map((s) {
      if (s.data()["type"] == "binary") {
        return BinaryQuestion.fromJson(s.id, s.data());
      } else {
        return GroupQuestion.fromJson(s.id, s.data());
      }
    });
    return questions.toList();
  }

  Future<Question> getQuestion(id) async {
    var ref = Collection.questions.ref(_db);

    final query = ref.doc(id);
    final snapshot = await query.get(GetOptions(source: CACHE));

    if (snapshot.exists) {
      if (snapshot.data()!["type"] == "binary") {
        return BinaryQuestion.fromJson(snapshot.id, snapshot.data()!);
      } else {
        return GroupQuestion.fromJson(snapshot.id, snapshot.data()!);
      }
    }

    throw NullThrownError();
  }

  Future<List<Form>> getForms({hospitalId, userId}) async {
    final ref = Collection.forms.ref(_db);
    var query = ref.orderBy("dateStarted");
    if (hospitalId != null) {
      query = query.where("hospital", isEqualTo: hospitalId);
    }
    if (userId != null) {
      query = query.where("user", isEqualTo: userId);
    }

    final snapshot = await query.get();
    final forms = snapshot.docs.map((s) => _formFromFirebase(s));
    return forms.toList();
  }

  Future<List<User>> getUserList() async {
    final ref = Collection.users.ref(_db);
    final query = ref;
    final snapshot = await query.get();
    final users = snapshot.docs.map((s) => User.fromJson(s.id, s.data()));
    return users.toList();
  }

  Future<List<Hospital>> getHospitals({bool fromCache = true}) async {
    var ref = Collection.hospitals.ref(_db);
    final query = fromCache ? ref : filterByModified(ref);
    final snapshot =
        await query.get(GetOptions(source: fromCache ? CACHE : SERVER));
    var hospitals = snapshot.docs.map((s) => Hospital.fromJson(s.id, s.data()));
    return hospitals.toList();
  }

  Future<void> updateQuestion(String questionId, String newInfo) async {
    var ref = Collection.questions.ref(_db).doc(questionId);

    var data = {'info': newInfo, 'lastModified': Timestamp.now()};

    return ref.set(data, SetOptions(merge: true));
  }

  /// Retrieves a single user document
  Future<User> getUser(String userId) async {
    var ref = Collection.users.ref(_db).doc(userId);
    var snapshot = await ref.get();
    return User.fromJson(snapshot.id, snapshot.data() ?? {});
  }

  Stream<List<FormType>> streamFormTypes() {
    var ref = Collection.formTypes.ref(_db);
    return ref.snapshots().map((querySnap) => querySnap.docs
        .map((doc) => FormType.fromJson(doc.id, doc.data()))
        .toList());
  }

  Stream<List<Form>> streamForms() {
    print('stream forms');
    var ref = _db
        .collection('forms')
        .where("user", isEqualTo: AuthService().user?.uid ?? "")
        .orderBy("dateStarted");
    return ref.snapshots().map((querySnap) {
      return querySnap.docs.map((doc) => _formFromFirebase(doc)).toList();
    });
  }

  String createForm(Form form) {
    var ref = Collection.forms.ref(_db).doc();

    var data = {
      'dateStarted': Timestamp.now(),
      'form_type': form.form_type,
      'hospital': form.hospital,
      'title': form.title,
      'user': AuthService().user?.uid ?? "",
      'lastModified': Timestamp.now(),
    };

    ref.set(data);

    return ref.id;
  }

  Future<void> updateForm(Form form) {
    var ref = Collection.forms.ref(_db).doc(form.id);

    var data = {
      'dateStarted': form.dateStarted,
      'form_type': form.form_type,
      'hospital': form.hospital,
      'title': form.title,
      'user': AuthService().user?.uid ?? "",
      'answers': form.answers,
      'lastModified': Timestamp.now()
    };

    return ref.set(data, SetOptions(merge: true));
  }

  Future<void> submitForm(Form form) {
    var ref = Collection.forms.ref(_db).doc(form.id);

    var data = {
      'dateStarted': form.dateStarted,
      'form_type': form.form_type,
      'hospital': form.hospital,
      'title': form.title,
      'user': AuthService().user?.uid ?? "",
      'answers': form.answers,
      'dateCompleted': Timestamp.now(),
      'dateReceived': FieldValue.serverTimestamp()
    };

    return ref.set(data, SetOptions(merge: true));
  }

  void createUser(User userDoc) {
    var user = AuthService().user;
    if (user != null) {
      var ref = Collection.users.ref(_db).doc(user.uid);
      ref.set(userDoc.toJson());
    }
  }

  Future<void> modifyAdmin(User userDoc, bool admin) {
    var ref = Collection.users.ref(_db).doc(userDoc.id);

    var data = {'admin': admin};

    return ref.set(data, SetOptions(merge: true));
  }

  Future<void> createHospital(String hospitalName) {
    var ref = Collection.hospitals.ref(_db).doc();

    var data = {'name': hospitalName, 'lastModified': Timestamp.now()};

    return ref.set(data);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print('$path/data.csv');
    return File('$path/data.csv');
  }

  Future<File> writeCSV(String data) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(data);
  }

  Future<void> generateCSV() async {
    var forms = await getForms();
    var questions = await getQuestions();
    var hospitals = await getHospitals();
    var users = await getUserList();

    var header = [
      'form_type_id',
      'form_id',
      'hospital_id',
      'hospital_name',
      'title',
      'user_id',
      'user_name',
      'date_started',
      'date_completed',
      'date_received'
    ];

    Map<String, String> questionKey = {};
    for (var i = 0; i < questions.length; i++) {
      var question = questions[i];
      questionKey[question.id] =
          question.variable.isEmpty ? question.info : question.variable;
      header.add(question.id);
    }

    Map<String, String> hospitalKey = {};
    for (var i = 0; i < hospitals.length; i++) {
      var hospital = hospitals[i];
      hospitalKey[hospital.id] = hospital.name;
    }

    Map<String, String> userKey = {};
    for (var i = 0; i < users.length; i++) {
      var user = users[i];
      userKey[user.id] = user.name["last"];
    }

    for (var i = 0; i < forms.length; i++) {
      var form = forms[i];
      if (form.id == "091019fa-39ea-45ad-82f6-47e7cff4cfb8") {
        for (var j = 0; j < form.answers.length; j++) {
          header.add(form.answers.keys.elementAt(j));
        }
      }
    }

    List<List<String>> data = [header];

    for (var i = 0; i < forms.length; i++) {
      var form = forms[i];
      List<String> formData = [
        form.form_type,
        form.id,
        form.hospital,
        hospitalKey[form.hospital] ?? "",
        form.title,
        form.user,
        userKey[form.user] ?? "",
        form.dateStarted?.toDate().toString() ?? "",
        form.dateCompleted?.toDate().toString() ?? "",
        form.dateReceived?.toDate().toString() ?? "",
      ];
      for (var j = 10; j < header.length; j++) {
        formData.add(form.answers[header[j]] ?? "");
      }
      data.add(formData);
    }

    for (var j = 10; j < header.length; j++) {
      data[0][j] = questionKey[data[0][j]] ?? data[0][j];
    }

    String csv = const ListToCsvConverter().convert(data);

    log(csv);
    writeCSV(csv);
    // exportCSV.myCSV(header, data);

    return;
  }

  Future<void> generateSpecificCSV() async {
    const id = "091019fa-39ea-45ad-82f6-47e7cff4cfb8";
    var forms = await getForms();
    var questions = await getQuestions();
    var hospitals = await getHospitals();
    var users = await getUserList();
    FormType survey = (await getFormTypes())[0];

    var sections = await getSections(survey);

    Map<String, Section> sectionsKey = {};

    for (var i = 0; i < sections.length; i++) {
      print(sections[i].questions.length);
      sectionsKey[sections[i].id] = sections.elementAt(i);
    }

    var specificHeader = ["Field", "category", "info", "variable", "answer"];

    Map<String, Question> questionKey = {};
    for (var i = 0; i < questions.length; i++) {
      var question = questions[i];
      questionKey[question.id] = questions[i];
      // header.add(question.id);
    }

    Map<String, String> hospitalKey = {};
    for (var i = 0; i < hospitals.length; i++) {
      var hospital = hospitals[i];
      hospitalKey[hospital.id] = hospital.name;
    }

    Map<String, String> userKey = {};
    for (var i = 0; i < users.length; i++) {
      var user = users[i];
      userKey[user.id] = user.name["last"];
    }

    List<List<String>> data = [specificHeader];

    for (var i = 0; i < forms.length; i++) {
      var form = forms[i];
      if (form.id == id) {
        data.add(["form_type", "metadata", "", "", form.form_type]);
        data.add(["form_id", "metadata", "", "", form.id]);
        data.add(["hospital_id", "metadata", "", "", form.hospital]);
        data.add([
          "hospital_name",
          "metadata",
          "",
          "",
          hospitalKey[form.hospital] ?? "unknown"
        ]);
        data.add(["title", "metadata", "", "", form.title]);
        data.add(["user_id", "metadata", "", "", form.user]);
        data.add([
          "user_last_name",
          "metadata",
          "",
          "",
          userKey[form.user] ?? "unknown"
        ]);
        data.add([
          "date_started",
          "metadata",
          "",
          "",
          form.dateStarted?.toDate().toString() ?? ""
        ]);
        data.add([
          "date_completed",
          "metadata",
          "",
          "",
          form.dateCompleted?.toDate().toString() ?? ""
        ]);
        data.add([
          "date_received",
          "metadata",
          "",
          "",
          form.dateReceived?.toDate().toString() ?? ""
        ]);

        Map<String, String> answerKey = {};

        for (int a = 0; a < form.answers.keys.length; a++) {
          var key = form.answers.keys.elementAt(a);
          answerKey[key] = form.answers[key] ?? "";
        }

        print("answerKey ${form.answers.keys.length}");

        print("survey ${survey.sections.length}");

        List<String> stack = [
          "KPfFgaHW6aAtSR9IkssC",
          "baMX3K0NPh0IUg17zQ3O",
          "F5MvGEP1QkF397yjADQp",
          "60MnQvNrFSs8lHUmuhVy",
          "r9LAsSrMKJqT0ZcYuXQ0",
          "mexoXZgqq90MjMFmHbvX",
          "046UyPnWlgPUNieXQwdL",
          "FfOSC2ATu2QKMEx3Msyr",
          "c2s93G586GUCfAfjOybR",
          "sLDqS0nhXfQTvT8OIJUt",
          "HF4r5MESTq0OlXIVcYm2",
          "YDJMjmbhagpJrNZoFNd6",
          "V7FJLUJ4QD8FBnDpgx1h",
          "13CqrbFKnlP0Gz0fZDLe",
          "FPZorJwLnknrxY6pQQnC",
          "LuzifRy3efMskSIGVipF",
          "mhkXUBIva5Ob8iayx1K8",
          "HU4WDNf771dsGGLPv6k1",
          "xiWEXBlsfgVm0tlpLxeW",
          "Y5KA68lNuM4Fx6oZQUbE",
          "uJ0hFbIe3GVesP089cJw",
          "UGefqiMcsB33sfsB08XN",
          "lvKkuKjmhkp2bhfJPtgs",
          "6HRTvM0y0nIgDUJTJKbo",
          "mVGSBnuEGgluT3TDaNfy",
          "1PQs8SVXBr5qXtaPnNCu",
          "MihGJeMHMDraSM6MBAdp",
          "VcmKfR1XWLleCnbeOs5M",
          "GTzxYeKFo1qCbvjbGQ3F",
          "NwcYShsFt326ruZEfgdq",
          "WLzVDtj7MI79doHt0e0T",
          "Z1YoNsy6Fip0oeaTeDi3",
          "hFjnCDmD90dXRKKpOZYw",
          "I6B0mjSVe8aKp8UtcsAg",
          "VlL0052Qs5a9iErjQIpV",
          "ht7cnModzOwXOnCjKYZ2",
          "GzwNIVOiq9Ox1kkwBSCg",
          "a2v6c4japSB8mytCTCrZ",
          "fzrdO0phqyl1zIi24jPX",
          "scmxr0achKgb3OFT6CNF",
          "rB78Mo3Es2M7qRxCmxXn",
          "zn2ZDcimULRxfcvDnC7a",
          "xSSaiiUUqE1ClqAT9ybv",
          "7MQYzmCI6UG7xUHPJWkp",
          "BDb9LGy5JFiyrc4h8iBY",
          "f99f6eVgpUO7hxOTwmfl",
          "VSWrCENsCXmBrTLqM035",
          "cHM47GSk5ZWcHw7zd6Di",
          "uvbLx8Xj9tu7Ml0fTdy0",
          "anbp73cszddFX3eErfvT",
          "0sQy1s8vk0W91zD6lG7w",
          "cStd7sFc1twumMKluYvn",
          "RTLUvLueVvLo5n7kRCQf"
        ];

        while (stack.isNotEmpty) {
          Question question = questionKey[stack.removeLast()] ?? Question();

          if (question.type == "binary") {
            BinaryQuestion bq = question as BinaryQuestion;
            print("added data ${bq.id}");
            data.add([
              question.id,
              bq.category,
              bq.info,
              bq.variable,
              answerKey[bq.id] ?? ""
            ]);
          } else {
            GroupQuestion gq = question as GroupQuestion;
            stack.addAll(gq.subquestions.reversed);
          }
        }
        // }
      }
    }

//["Field", "category", "info", "varible", "answer"];

    String csv = const ListToCsvConverter().convert(data);
    writeCSV(csv);
    // exportCSV.myCSV(header, data);

    return;
  }
}
