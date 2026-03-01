import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert'; // For JSON decoding
import 'package:flutter/services.dart' show rootBundle; // For loading assets
import 'educ.dart'; // Import EducPage for navigation
import 'cam.dart'; // Import CamPage for navigation

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, Object>> questions = [];
  int _questionIndex = 0;
  int _totalScore = 0;
  int _remainingTime = 10;
  Timer? _timer;
  int _selectedIndex = 1; // Index for bottom navigation bar (lightbulb is selected)

  @override
  void initState() {
    super.initState();
    loadQuestions(); // Load questions from JSON file
  }

  // Load questions from the JSON file
  Future<void> loadQuestions() async {
    String data = await rootBundle.loadString('assets/questions.json');
    final List<dynamic> jsonData = json.decode(data);
    setState(() {
      questions = jsonData.map((item) => Map<String, Object>.from(item)).toList();
      questions.shuffle(); // Shuffle the questions list
      startTimer(); // Start the timer after loading and shuffling questions
    });
  }

  void startTimer() {
    _remainingTime = 10; // Set time to 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        _goToNextQuestion();
      }
    });
  }

  void _goToNextQuestion() {
    if (_questionIndex < questions.length - 1) {
      setState(() {
        _questionIndex++;
        startTimer(); // Restart the timer for the next question
      });
    } else {
      _showScoreDialog(); // End the quiz and show score
    }
  }

  void _answerQuestion(int score) {
    _totalScore += score;
    _timer?.cancel(); // Cancel timer when the answer is selected
    _goToNextQuestion();
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quiz Completed!'),
        content: Text('Your score is: $_totalScore/${questions.length}'),
        actions: [
          TextButton(
            child: const Text('Restart'),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _questionIndex = 0;
                _totalScore = 0;
                questions.shuffle(); // Shuffle questions when restarting the quiz
                startTimer(); // Restart quiz and timer
              });
            },
          ),
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Exit quiz
            },
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on the selected index
    if (index == 0) { // If book icon is clicked
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EducPage()), // Navigate to EducPage
      );
    } else if (index == 1) { // If lightbulb is clicked
      // Already on QuizPage, do nothing
    } else if (index == 2) { // If camera is clicked
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CamPage()), // Navigate to CamPage
      );
    } else if (index == 3) { // If person icon is clicked
      // Navigate to ProfilePage (if needed)
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Dispose the timer when leaving the page
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Environment Quiz'),
      ),
      body: questions.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show loading until questions load
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    questions[_questionIndex]['questionText'] as String,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ...((questions[_questionIndex]['answers'] as List<dynamic>).map((answer) {
                  return ElevatedButton(
                    onPressed: () => _answerQuestion(answer['score'] as int),
                    child: Text(answer['text'] as String),
                  );
                })),
                const SizedBox(height: 20),
                Text(
                  'Time remaining: $_remainingTime seconds',
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
              ],
            ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        color: const Color(0xFF9FF542), // Light green for the bottom navigation bar
        child: BottomNavigationBar(
          backgroundColor: Colors.lightGreen, // Keep background transparent for the container to handle color
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: '', // No label for icons
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
          currentIndex: _selectedIndex, // Track selected index
          selectedItemColor: Colors.black, // Dark color for selected item
          unselectedItemColor: Colors.black54, // Slightly lighter color for unselected items
          onTap: _onItemTapped, // Handle tap to switch active tab
          showSelectedLabels: false, // Hide labels
          showUnselectedLabels: false,
        ),
      ),
    );
  }
}