import 'levels.dart';

class GameMap {
  static late LevelData level;

  static late List<List<int>> layout;

  static int get width => level.width;
  static int get height => level.height;

  static void loadLevel(LevelData data) {
    level = data;
    resetMap();
  }

  static void resetMap() {
    layout = level.layout.map((row) => List<int>.from(row)).toList();
  }

  static bool _outside(int x, int y) =>
      x < 0 || x >= width || y < 0 || y >= height;

  static bool isWall(int x, int y) {
    if (_outside(x, y)) return true;
    final c = layout[y][x];
    return c == 1 || c == 4;
  }

  static bool isSolid(int x, int y) {
    if (_outside(x, y)) return true;
    return layout[y][x] == 1;
  }

  static bool isDoor(int x, int y) {
    if (_outside(x, y)) return false;
    return layout[y][x] == 4;
  }
}