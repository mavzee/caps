import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'educ.dart';
import 'cam.dart';

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
  int _selectedIndex = 1;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  
  // Fun elements
  int _streak = 0;
  String _currentMascot = "🌱";
  final List<String> _mascots = ["🌱", "🌍", "♻️", "🐢", "🌳"];
  
  // Sound-like visual feedback
  bool _showCorrectAnimation = false;
  bool _showWrongAnimation = false;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    String data = await rootBundle.loadString('assets/questions.json');
    final List<dynamic> jsonData = json.decode(data);
    setState(() {
      questions = jsonData.map((item) => Map<String, Object>.from(item)).toList();
      questions.shuffle();
      startTimer();
    });
  }

  void startTimer() {
    _remainingTime = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        if (!_isAnswered) {
          _handleTimeout();
        }
      }
    });
  }

  void _handleTimeout() {
    setState(() {
      _streak = 0;
      _showWrongAnimation = true;
      _currentMascot = "😢";
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showWrongAnimation = false;
        _currentMascot = _mascots[_questionIndex % _mascots.length];
      });
    });
    
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    if (_questionIndex < questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
        startTimer();
        _currentMascot = _mascots[_questionIndex % _mascots.length];
      });
    } else {
      _showResultDialog();
    }
  }

  void _answerQuestion(int score, int answerIndex) {
    if (!_isAnswered) {
      bool isCorrect = score > 0;
      
      setState(() {
        _totalScore += score;
        _selectedAnswerIndex = answerIndex;
        _isAnswered = true;
        
        if (isCorrect) {
          _streak++;
          _showCorrectAnimation = true;
          _currentMascot = _streak >= 3 ? "🔥" : "🎉";
        } else {
          _streak = 0;
          _showWrongAnimation = true;
          _currentMascot = "😢";
        }
      });
      
      _timer?.cancel();
      
      // Reset animations
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _showCorrectAnimation = false;
          _showWrongAnimation = false;
          if (isCorrect) {
            _currentMascot = _mascots[(_questionIndex + 1) % _mascots.length];
          } else {
            _currentMascot = _mascots[_questionIndex % _mascots.length];
          }
        });
      });
      
      Future.delayed(const Duration(milliseconds: 800), () {
        _goToNextQuestion();
      });
    }
  }

  void _showResultDialog() {
    double percentage = _totalScore / questions.length;
    
    String emoji;
    String title;
    Color color;
    
    if (percentage >= 0.8) {
      emoji = "🏆";
      title = "Eco Champion!";
      color = Colors.amber;
    } else if (percentage >= 0.6) {
      emoji = "🌟";
      title = "Great Job!";
      color = Colors.blue;
    } else if (percentage >= 0.4) {
      emoji = "🌱";
      title = "Good Try!";
      color = Colors.green;
    } else {
      emoji = "💚";
      title = "Keep Learning!";
      color = Colors.orange;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 50)),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    '$_totalScore/${questions.length}',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Best Streak: $_streak 🔥',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _questionIndex = 0;
      _totalScore = 0;
      _streak = 0;
      _selectedAnswerIndex = null;
      _isAnswered = false;
      questions.shuffle();
      startTimer();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EducPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CamPage()),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              _currentMascot,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 8),
            const Text(
              'Eco Quiz',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_totalScore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_streak > 1) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.whatshot, color: Colors.orange, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$_streak',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: questions.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.green),
                    SizedBox(height: 20),
                    Text('Loading Fun Quiz...'),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Progress Row
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (_questionIndex + 1) / questions.length,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _streak >= 3 ? Colors.orange : Colors.green[700]!,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.2),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Text(
                            '${_questionIndex + 1}/${questions.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Timer
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _remainingTime <= 3 
                                ? Colors.red.withOpacity(0.3) 
                                : Colors.green.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: _remainingTime / 10,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _remainingTime <= 3 ? Colors.red : Colors.green[700]!,
                              ),
                              strokeWidth: 4,
                            ),
                            Text(
                              '$_remainingTime',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _remainingTime <= 3 ? Colors.red : Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Question Card
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      transform: _showWrongAnimation
                          ? (Matrix4.identity()..translate(5.0, 0.0, 0.0))
                          : Matrix4.identity(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _showCorrectAnimation 
                              ? Colors.green[100] 
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _streak >= 3 ? "🔥 STREAK! 🔥" : "🌍 ECO QUIZ 🌱",
                                  style: TextStyle(
                                    color: _streak >= 3 ? Colors.orange : Colors.green[700],
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              questions[_questionIndex]['questionText'] as String,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Answers
                    Expanded(
                      child: ListView.builder(
                        itemCount: (questions[_questionIndex]['answers'] as List<dynamic>).length,
                        itemBuilder: (ctx, index) {
                          var answer = (questions[_questionIndex]['answers'] as List<dynamic>)[index];
                          bool isCorrect = answer['score'] > 0;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: ElevatedButton(
                                onPressed: _isAnswered 
                                    ? null 
                                    : () => _answerQuestion(answer['score'] as int, index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getAnswerColor(index),
                                  foregroundColor: _isAnswered ? Colors.black87 : Colors.white,
                                  disabledBackgroundColor: _getAnswerColor(index),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                      color: _selectedAnswerIndex == index
                                          ? (isCorrect ? Colors.green : Colors.red)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          ['A', 'B', 'C', 'D'][index],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        answer['text'] as String,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (_isAnswered && _selectedAnswerIndex == index)
                                      Icon(
                                        isCorrect ? Icons.check_circle : Icons.cancel,
                                        color: isCorrect ? Colors.green[300] : Colors.red[300],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Fun message at bottom
                    if (_streak >= 3)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "🔥 STREAK: $_streak correct in a row! 🔥",
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
         
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Color _getAnswerColor(int answerIndex) {
    if (!_isAnswered) return Colors.green[700]!;
    if (_selectedAnswerIndex == answerIndex) {
      var answers = questions[_questionIndex]['answers'] as List<dynamic>;
      int score = answers[answerIndex]['score'] as int;
      return score > 0 ? Colors.green : Colors.red;
    }
    return Colors.grey[300]!;
  }
}