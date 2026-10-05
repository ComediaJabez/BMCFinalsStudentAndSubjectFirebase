import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const FormPage(),
    );
  }
}


class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    sectionController.dispose();
    yearController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (nameController.text.trim().isEmpty ||
        sectionController.text.trim().isEmpty ||
        yearController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecondScreen(
          name: nameController.text.trim(),
          section: sectionController.text.trim(),
          year: yearController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.school,
              size: 80,
            ),

            const SizedBox(height: 20),

            const Text(
              'Student Registration',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // NAME
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 15),

            // SECTION
            TextField(
              controller: sectionController,
              decoration: const InputDecoration(
                labelText: 'Section',
                hintText: 'Enter your section',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.class_),
              ),
            ),

            const SizedBox(height: 15),

            // YEAR LEVEL
            TextField(
              controller: yearController,
              decoration: const InputDecoration(
                labelText: 'Year Level',
                hintText: 'Enter your year level',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),

            const SizedBox(height: 30),

            // NEXT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: nextPage,
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  final String name;
  final String section;
  final String year;

  const SecondScreen({
    super.key,
    required this.name,
    required this.section,
    required this.year,
  });

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final TextEditingController subject1Controller = TextEditingController();
  final TextEditingController schedule1Controller = TextEditingController();

  final TextEditingController subject2Controller = TextEditingController();
  final TextEditingController schedule2Controller = TextEditingController();

  final TextEditingController subject3Controller = TextEditingController();
  final TextEditingController schedule3Controller = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isSaving = false;

  @override
  void dispose() {
    subject1Controller.dispose();
    schedule1Controller.dispose();

    subject2Controller.dispose();
    schedule2Controller.dispose();

    subject3Controller.dispose();
    schedule3Controller.dispose();

    super.dispose();
  }

  Future<void> saveData() async {
    if (subject1Controller.text.trim().isEmpty ||
        schedule1Controller.text.trim().isEmpty ||
        subject2Controller.text.trim().isEmpty ||
        schedule2Controller.text.trim().isEmpty ||
        subject3Controller.text.trim().isEmpty ||
        schedule3Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all subject and schedule fields'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // SAVE TO FIREBASE
      DocumentReference document =
          await firestore.collection('students').add({
        'name': widget.name,
        'section': widget.section,
        'year': widget.year,

        'subject1': subject1Controller.text.trim(),
        'schedule1': schedule1Controller.text.trim(),

        'subject2': subject2Controller.text.trim(),
        'schedule2': schedule2Controller.text.trim(),

        'subject3': subject3Controller.text.trim(),
        'schedule3': schedule3Controller.text.trim(),

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data saved successfully!'),
        ),
      );

      // GO TO THIRD PAGE
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ThirdScreen(
            documentId: document.id,
            name: widget.name,
            section: widget.section,
            year: widget.year,
            subject1: subject1Controller.text.trim(),
            schedule1: schedule1Controller.text.trim(),
            subject2: subject2Controller.text.trim(),
            schedule2: schedule2Controller.text.trim(),
            subject3: subject3Controller.text.trim(),
            schedule3: schedule3Controller.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving data: $e'),
        ),
      );
    }
  }

  Widget scheduleField({
    required String subjectLabel,
    required String scheduleLabel,
    required TextEditingController subjectController,
    required TextEditingController scheduleController,
  }) {
    return Column(
      children: [
        TextField(
          controller: subjectController,
          decoration: InputDecoration(
            labelText: subjectLabel,
            hintText: 'Enter subject',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.book),
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: scheduleController,
          decoration: InputDecoration(
            labelText: scheduleLabel,
            hintText: 'Example: Monday 8:00 AM',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.schedule),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Schedule'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Subject Schedule',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '${widget.name} • ${widget.section} • ${widget.year}',
              style: const TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            // SUBJECT 1
            scheduleField(
              subjectLabel: 'Subject 1',
              scheduleLabel: 'Schedule 1',
              subjectController: subject1Controller,
              scheduleController: schedule1Controller,
            ),

            const SizedBox(height: 20),

            // SUBJECT 2
            scheduleField(
              subjectLabel: 'Subject 2',
              scheduleLabel: 'Schedule 2',
              subjectController: subject2Controller,
              scheduleController: schedule2Controller,
            ),

            const SizedBox(height: 20),

            // SUBJECT 3
            scheduleField(
              subjectLabel: 'Subject 3',
              scheduleLabel: 'Schedule 3',
              subjectController: subject3Controller,
              scheduleController: schedule3Controller,
            ),

            const SizedBox(height: 30),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveData,
                icon: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isSaving ? 'Saving...' : 'Save',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdScreen extends StatelessWidget {
  final String documentId;

  final String name;
  final String section;
  final String year;

  final String subject1;
  final String schedule1;

  final String subject2;
  final String schedule2;

  final String subject3;
  final String schedule3;

  const ThirdScreen({
    super.key,
    required this.documentId,
    required this.name,
    required this.section,
    required this.year,
    required this.subject1,
    required this.schedule1,
    required this.subject2,
    required this.schedule2,
    required this.subject3,
    required this.schedule3,
  });

  Widget informationBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget subjectBox({
    required String subject,
    required String schedule,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 20),
              const SizedBox(width: 8),
              Text(schedule),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title Store'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle,
              size: 80,
            ),

            const SizedBox(height: 15),

            const Text(
              'Registration Saved!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // STUDENT INFORMATION
            informationBox(
              title: 'Name',
              value: name,
              icon: Icons.person,
            ),

            informationBox(
              title: 'Section',
              value: section,
              icon: Icons.class_,
            ),

            informationBox(
              title: 'Year Level',
              value: year,
              icon: Icons.school,
            ),

            const SizedBox(height: 15),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Subject Schedule',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // SUBJECTS
            subjectBox(
              subject: subject1,
              schedule: schedule1,
            ),

            subjectBox(
              subject: subject2,
              schedule: schedule2,
            ),

            subjectBox(
              subject: subject3,
              schedule: schedule3,
            ),

            const SizedBox(height: 20),

            // BACK HOME
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormPage(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'New Registration',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

