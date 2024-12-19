import 'package:flutter/material.dart';
import 'dart:math';

class AnimationPage extends StatefulWidget {
  @override
  BalanceGame createState() => BalanceGame();
}

class BalanceGame extends State<AnimationPage>
    with SingleTickerProviderStateMixin {
  double playerX = 0; // موقع اللاعب
  double platformX = 0; // موقع المنصة
  double platformWidth = 30; // عرض المنصة
  int score = 0; // عداد النقاط
  bool gameOver = false;
  bool gameStarted = false; // حالة بدء اللعبة

  late AnimationController platformController;

  @override
  void initState() {
    super.initState();
    platformController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() {
          platformX = sin(platformController.value * 2 * pi) * 0.5;
          if (!gameOver && gameStarted) {
            score++;
            platformWidth =
                max(100, platformWidth - 0.02); // تصغير المنصة تدريجيًا
          }
        });
        checkGameOver();
      });
    Future.delayed(Duration.zero, showWelcomeDialog);
  }

  void movePlayer(double delta) {
    setState(() {
      playerX += delta;
      if (playerX < -1) playerX = -1; // منع الخروج يسار
      if (playerX > 1) playerX = 1; // منع الخروج يمين
    });
  }

  void checkGameOver() {
    if ((playerX - platformX).abs() > platformWidth / 200) {
      platformController.stop();
      setState(() {
        gameOver = true;
      });
    }
  }

  void resetGame() {
    setState(() {
      playerX = 0;
      platformX = 0;
      platformWidth = 30;
      score = 0;
      gameOver = false;
    });
    platformController.repeat(reverse: true);
  }

  void startGame() {
    setState(() {
      gameStarted = true;
    });
    platformController.repeat(reverse: true);
  }

  void showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // منع إغلاق الحوار بالضغط خارج الصندوق
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'مرحبًا بك!',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'مرحبًا بك في لعبة التحدي! '
            'قم بتحريك اللاعب باستخدام الأسهم للحفاظ على توازنه على المنصة الحمراء. '
            'إذا خرج اللاعب عن المنصة، ستنتهي اللعبة. حاول أن تسجل أكبر عدد من النقاط!',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // إغلاق الحوار
                  startGame(); // بدء اللعبة
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text(
                  'ابدأ اللعبة',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    platformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          Align(
            alignment: const Alignment(0, 0.8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment(playerX, 0),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sports_esports,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // المنصة
          Align(
            alignment: const Alignment(0, 0.9),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1),
              alignment: Alignment(platformX, 0),
              child: Container(
                width: platformWidth,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // عداد النقاط
          Positioned(
            top: 50,
            left: 20,
            child: Text(
              "Score: $score",
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          // واجهة التحكم
          if (gameOver)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Game Over',
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Restart',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          if (!gameOver && gameStarted)
            Align(
              alignment: const Alignment(0, 0.95),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => movePlayer(-0.1),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_left, color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => movePlayer(0.1),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_right, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
