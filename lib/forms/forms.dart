import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespine/app_state.dart';
import 'package:safespine/forms/form_type_item.dart';
import 'package:safespine/shared/bottom_nav.dart';
import 'package:safespine/shared/loading.dart';

class FormsScreen extends StatefulWidget {
  const FormsScreen({super.key});

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> {
  @override
  void initState() {
    print("init FormsScreen");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("add post frame callback");
      Provider.of<AppState>(context, listen: false).refreshFromFirebase();
    });
    super.initState();
  }

  Widget getLoading() {
    return const Center(
        child: SizedBox(height: 25, width: 25, child: Loader()));
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<AppState>(context).isLoading
        ? getLoading()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              title: const Text('Start Form'),
              leading: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/csv',
                    );
                  },
                  child: const Icon(
                    Icons.document_scanner,
                    size: 26.0,
                  ),
                ),
                // TODO: remove
                // child: GestureDetector(
                //   onTap: () {
                //     Navigator.pushNamed(
                //       context,
                //       '/addHospital',
                //     );
                //   },
                //   child: const Icon(
                //     Icons.local_hospital,
                //     size: 26.0,
                //   ),
                // ),
              ),
              actions: [
                if (!Provider.of<bool>(context))
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.signal_wifi_connected_no_internet_4,
                        size: 26.0,
                      ),
                    ),
                  ),
                // Modify Questions Sheet
                // GestureDetector(
                //     onTap: () {
                //       Navigator.pushNamed(
                //         context,
                //         '/modifyQuestions',
                //       );
                //     },
                //     child: const Icon(Icons.book))
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: Provider.of<AppState>(context)
                  .formats
                  .map((formType) =>
                      Flexible(child: FormTypeItem(form: formType)))
                  .toList(),
            ),
            bottomNavigationBar: const BottomNavBar(),
          );
  }
}
