import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth.dart';

// class SignupScreen extends StatelessWidget {
//   const SignupScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Container());
//   }
// }

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Orthopaedic Link',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Signup for SafeSpine Inventory',
                      style: GoogleFonts.inter(
                        fontSize: 23,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 35),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                        //...
                        ),
                    const SizedBox(height: 30),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          FontAwesomeIcons.user,
                          color: Colors.white,
                          size: 20,
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(24),
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          AuthService().createUser(
                              emailController.text, passwordController.text);
                        },
                        label:
                            const Text("Sign Up", textAlign: TextAlign.center),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () => {Navigator.pop(context)},
                      child: const Text('Return to Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
