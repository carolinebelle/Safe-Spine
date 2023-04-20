import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safespine/services/auth.dart';
import 'package:safespine/services/models.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:to_csv/to_csv.dart' as exportCSV;

import 'package:path_provider/path_provider.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Form formFromFirebase(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
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

  Future<List<FormType>> getFormTypes() async {
    var ref = _db.collection('form_types');
    var snapshot = await ref.get();
    var formTypes = snapshot.docs.map((s) => FormType.fromJson(s.id, s.data()));
    return formTypes.toList();
  }

  Future<List<Section>> getSections(formType) async {
    var ref = _db.collection('form_types/$formType/Sections');
    var snapshot = await ref.get();
    var sections = snapshot.docs.map((s) => Section.fromJson(s.id, s.data()));
    return sections.toList();
  }

  Future<List<Question>> getQuestions() async {
    var ref = _db.collection('questions');
    var snapshot = await ref.get();
    Iterable<Question> questions = snapshot.docs.map((s) {
      if (s.data()["type"] == "binary") {
        return BinaryQuestion.fromJson(s.id, s.data());
      } else {
        return GroupQuestion.fromJson(s.id, s.data());
      }
    });
    return questions.toList();
  }

  Future<List<Form>> getForms({hospitalId, userId}) async {
    var ref = _db.collection('forms').orderBy("dateStarted");
    if (hospitalId != null) {
      ref = ref.where("hospital", isEqualTo: hospitalId);
    }
    if (userId != null) {
      ref = ref.where("user", isEqualTo: userId);
    }
    var snapshot = await ref.get();
    var forms = snapshot.docs.map((s) => formFromFirebase(s));
    return forms.toList();
  }

  Future<List<User>> getUserList() async {
    var ref = _db.collection('users');
    var snapshot = await ref.get();
    var users = snapshot.docs.map((s) => User.fromJson(s.id, s.data()));
    return users.toList();
  }

  Future<List<Hospital>> getHospitals() async {
    var ref = _db.collection('hospitals');
    var snapshot = await ref.get();
    var hospitals = snapshot.docs.map((s) => Hospital.fromJson(s.id, s.data()));
    return hospitals.toList();
  }

  /// Retrieves a single section document
  Future<Section> getSection(String formId, String sectionId) async {
    var ref = _db.collection('quizzes/$formId/Sections').doc(sectionId);
    var snapshot = await ref.get();
    return Section.fromJson(snapshot.id, snapshot.data() ?? {});
  }

  /// Retrieves a single question document
  Future<Question> getQuestion(String questionId) async {
    var ref = _db.collection('questions').doc(questionId);
    var snapshot = await ref.get();
    if (snapshot.data()?["type"] == "binary") {
      return BinaryQuestion.fromJson(snapshot.id, snapshot.data() ?? {});
    } else {
      return GroupQuestion.fromJson(snapshot.id, snapshot.data() ?? {});
    }
  }

  Future<void> updateQuestion(String questionId, String newInfo) async {
    var ref = _db.collection('questions').doc(questionId);

    var data = {
      'info': newInfo,
    };

    return ref.set(data, SetOptions(merge: true));
  }

  /// Retrieves a single user document
  Future<User> getUser(String userId) async {
    var ref = _db.collection('users').doc(userId);
    var snapshot = await ref.get();
    return User.fromJson(snapshot.id, snapshot.data() ?? {});
  }

  Stream<List<FormType>> streamFormTypes() {
    var ref = _db.collection('form_types');
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
      return querySnap.docs.map((doc) => formFromFirebase(doc)).toList();
    });
  }

  // Stream<List<Form>> streamForms() {
  //   return AuthService().userStream.switchMap((user) {
  //     if (user != null) {
  //       print("user is not null");
  //       var ref = _db.collection('forms').where("user", isEqualTo: user.uid);
  //       return ref.snapshots().map((querySnap) => querySnap.docs
  //           .map((doc) => Form.fromJson(doc.id, doc.data()))
  //           .toList());
  //     } else {
  //       print("user is null");
  //       return Stream.fromIterable([]);
  //     }
  //   });
  // }

  String createForm(Form form) {
    var ref = _db.collection('forms').doc();

    var data = {
      'dateStarted': Timestamp.now(),
      'form_type': form.form_type,
      'hospital': form.hospital,
      'title': form.title,
      'user': AuthService().user?.uid ?? "",
    };

    ref.set(data);

    return ref.id;
  }

  Future<void> updateForm(Form form) {
    var ref = _db.collection('forms').doc(form.id);

    var data = {
      'dateStarted': form.dateStarted,
      'form_type': form.form_type,
      'hospital': form.hospital,
      'title': form.title,
      'user': AuthService().user?.uid ?? "",
      'answers': form.answers,
    };

    return ref.set(data, SetOptions(merge: true));
  }

  Future<void> submitForm(Form form) {
    var ref = _db.collection('forms').doc(form.id);

    var data = {
      'dateStarted': form.dateStarted,
      'form_type': form.form_type,
      'hospital': form.hospital,
      'title': form.title,
      'user': AuthService().user?.uid ?? "",
      'answers': form.answers,
      'dateCompleted': Timestamp.now(),
      'dateReceived': FieldValue.serverTimestamp(),
    };

    return ref.set(data, SetOptions(merge: true));
  }

  void createUser(User userDoc) {
    var user = AuthService().user;
    if (user != null) {
      var ref = _db.collection('users').doc(user.uid);
      ref.set(userDoc.toJson());
    }
  }

  Future<void> modifyAdmin(User userDoc, bool admin) {
    var ref = _db.collection('users').doc(userDoc.id);

    var data = {'admin': admin};

    return ref.set(data, SetOptions(merge: true));
  }

  Future<void> createHospital(String hospitalName) {
    var ref = _db.collection('hospitals').doc();

    var data = {'name': hospitalName};

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

        // for (var s = 0; s < survey.sections.length; s++) {
        //   print(survey.sections[s]);
        //   Section currentSection =
        //       await getSection(form.form_type, survey.sections[s]);

        //   print(currentSection.questions.length);
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
