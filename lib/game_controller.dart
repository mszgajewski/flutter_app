import 'dart:math';
import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/components/health_bar.dart';
import 'package:flutter_app/components/highscore_text.dart';
import 'package:flutter_app/enemy_spawner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/enemy.dart';
import 'components/player.dart';
import 'components/score_text.dart';
import 'package:flutter_app/stan.dart';
import 'components/start_text.dart';

class GameController extends Game {
  final SharedPreferences storage;
  Random rand;
  Size screenSize;
  double tileSize;
  Player player;
  EnemySpawner enemySpawner;
  List<Enemy> enemies;
  HealthBar healthBar;
  int score;
  ScoreText scoreText;
  Stan stan;
  HighscoreText highscoreText;
  StartText startText;

  GameController(this.storage){
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    stan = Stan.menu;
    rand = Random();
    player = Player(this);
    // ignore: deprecated_member_use
    enemies = List<Enemy>();
    enemySpawner = EnemySpawner(this);
    healthBar = HealthBar(this);
    score = 0;
    scoreText = ScoreText(this);
    highscoreText = HighscoreText(this);
    startText = StartText(this);
  }

  void render(Canvas c) {

    Rect background = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint backgroundPaint = Paint()..color = Color(0xFFFAFAFA);
     c.drawRect(background, backgroundPaint);

    player.render(c);
    if (stan == Stan.menu) {
      startText.render(c);
      highscoreText.render(c);
    } else {
      enemies.forEach((Enemy enemy) => enemy.render(c));
      scoreText.render(c);
      healthBar.render(c);
    }
  }

  void update(double t) {
    if (stan == Stan.menu) {
      startText.update(t);
      highscoreText.update(t);
    } else {
      enemySpawner.update(t);
      enemies.forEach((Enemy enemy) => enemy.update(t));
      enemies.removeWhere((Enemy enemy) => enemy.isDead);
      player.update(t);
      scoreText.update(t);
      healthBar.update(t);
    }

  }

  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / 10;
  }

  void onTapDown (TapDownDetails d) {
    if (stan == Stan.menu) {
      stan = Stan.playing;
    } else {
      enemies.forEach((Enemy enemy) {
        if (enemy.enemyRect.contains(d.globalPosition)) {
          enemy.onTapDown();
        }
      });
    }
  }
  void spawnEnemy() {
    double x, y;
    switch (rand.nextInt(4)) {
      case 0:
    //Top
        x = rand.nextDouble() * screenSize.width;
        y = -tileSize * 2.5;
        break;
      case 1:
        //Right
        x = screenSize.width + tileSize * 2.5;
        y = rand.nextDouble() *screenSize.width;
        break;
      case 2:
        //Bottom
        x = rand.nextDouble() * screenSize.width;
        y = screenSize.height + tileSize * 2.5;
        break;
      case 3:
        x = -tileSize * 2.5;
        y = rand.nextDouble() * screenSize.height;
        break;
    }
    enemies.add(Enemy(this, x, y));
  }
}