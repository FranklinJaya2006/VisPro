import 'dart:io';
import 'dart:math';
import 'dart:async';

class CicakGame {
  final String foodSymbol;
  late List<List<int>> cicakBody;
  late int foodX;
  late int foodY;
  late int width;
  late int height;
  late String direction;
  late bool gameOver;

  CicakGame(this.foodSymbol) {
    List<int> terminalSize = _getTerminalSize();
    width = terminalSize[0];
    height = terminalSize[1];
    cicakBody = [
      [width ~/ 2, height ~/ 2],     // Head
      [width ~/ 2 - 1, height ~/ 2], // Body
      [width ~/ 2 - 2, height ~/ 2], // Body
      [width ~/ 2 - 3, height ~/ 2], // Body
      [width ~/ 2 - 2, height ~/ 2], // Body
    ];
    direction = 'right';
    gameOver = false;
    _placeFoodRandomly();
  }

  List<int> _getTerminalSize() {
    try {
      ProcessResult result = Process.runSync('stty', ['size']);
      String output = result.stdout.toString().trim();
      if (output.isEmpty) {
        return [80, 24];
      }
      List<String> size = output.split(' ');
      if (size.length != 2) {
        return [80, 24];
      }
      int height = int.parse(size[0]);
      int width = int.parse(size[1]);
      return [width, height];
    } catch (e) {
      return [80, 24];
    }
  }

  void _placeFoodRandomly() {
    Random random = Random();
    do {
      foodX = random.nextInt(width);
      foodY = random.nextInt(height);
    } while (cicakBody.any((segment) => segment[0] == foodX && segment[1] == foodY));
  }

  void move() {
    List<int> newHead = List.from(cicakBody.first);
    switch (direction) {
      case 'up':
        newHead[1] = (newHead[1] - 1 + height) % height;
        break;
      case 'down':
        newHead[1] = (newHead[1] + 1) % height;
        break;
      case 'left':
        newHead[0] = (newHead[0] - 1 + width) % width;
        break;
      case 'right':
        newHead[0] = (newHead[0] + 1) % width;
        break;
    }

    if (cicakBody.sublist(1).any((segment) => segment[0] == newHead[0] && segment[1] == newHead[1])) {
      gameOver = true;
      return;
    }

    cicakBody.insert(0, newHead);

    if (newHead[0] == foodX && newHead[1] == foodY) {
      _placeFoodRandomly();
      // Add a new body segment
      cicakBody.insert(1, List.from(cicakBody[1]));
    } else {
      cicakBody.removeLast();
    }
  }

  void chooseDirection() {
    List<int> head = cicakBody.first;
    List<String> possibleDirections = ['up', 'down', 'left', 'right'];
    possibleDirections.remove(_oppositeDirection(direction));

    possibleDirections.sort((a, b) {
      int distanceA = _getDistance(_getNextPosition(a), [foodX, foodY]);
      int distanceB = _getDistance(_getNextPosition(b), [foodX, foodY]);
      return distanceA.compareTo(distanceB);
    });

    direction = possibleDirections.first;
  }

  String _oppositeDirection(String dir) {
    switch (dir) {
      case 'up': return 'down';
      case 'down': return 'up';
      case 'left': return 'right';
      case 'right': return 'left';
      default: return '';
    }
  }

  List<int> _getNextPosition(String dir) {
    List<int> nextPos = List.from(cicakBody.first);
    switch (dir) {
      case 'up':
        nextPos[1] = (nextPos[1] - 1 + height) % height;
        break;
      case 'down':
        nextPos[1] = (nextPos[1] + 1) % height;
        break;
      case 'left':
        nextPos[0] = (nextPos[0] - 1 + width) % width;
        break;
      case 'right':
        nextPos[0] = (nextPos[0] + 1) % width;
        break;
    }
    return nextPos;
  }

  int _getDistance(List<int> pos1, List<int> pos2) {
    return (pos1[0] - pos2[0]).abs() + (pos1[1] - pos2[1]).abs();
  }

  void draw() {
    List<List<String>> grid = List.generate(height, (_) => List.generate(width, (_) => ' '));

    // Draw cicak body
    for (int i = 1; i < cicakBody.length - 1; i++) {
      grid[cicakBody[i][1]][cicakBody[i][0]] = '*';
    }

    // Draw cicak head
    var head = cicakBody.first;
    grid[head[1]][head[0]] = _getHeadSymbol();

    // Draw cicak legs and arms
    if (cicakBody.length > 2) {
      var neck = cicakBody[1];
      _drawLimbs(grid, neck);
    }
    // Draw cicak legs and arms
    if (cicakBody.length > 3) {
      var neck = cicakBody[cicakBody.length - 2];
      _drawLimbs(grid, neck);
    }

    // Draw food
    grid[foodY][foodX] = foodSymbol;

    print('\x1B[2J\x1B[0;0H'); // Clear screen
    for (var row in grid) {
      print(row.join());
    }
  }

  String _getHeadSymbol() {
    switch (direction) {
      case 'up': return '^';
      case 'down': return 'v';
      case 'left': return '<';
      case 'right': return '>';
      default: return 'o';
    }
  }

  void _drawLimbs(List<List<String>> grid, List<int> neckPos) {
    var x = neckPos[0];
    var y = neckPos[1];

    // Draw arms
    if (y > 0) grid[y-1][x] = '*';
    if (y < height - 1) grid[y+1][x] = '*';

    // Draw legs
    if (x > 0) grid[y][x-1] = '*';
    if (x < width - 1) grid[y][x+1] = '*';
  }
  

  void start() {
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (gameOver) {
        timer.cancel();
        return;
      }

      chooseDirection();
      move();
      draw();
    });
  }
}

void main() {
  CicakGame game = CicakGame('O');
  game.start();
}