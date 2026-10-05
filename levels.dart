class LevelData {
  final String name;
  final List<List<int>> layout;

  final int houseX;
  final int houseY;

  final int pacStartX;
  final int pacStartY;

  final double ghostSpeed;

  final double frightenedSpeed;

  final int frightenedMs;

  final int scatterMs;
  final int chaseMs;

  final List<int> releaseDotLimits;

  const LevelData({
    required this.name,
    required this.layout,
    required this.houseX,
    required this.houseY,
    required this.pacStartX,
    required this.pacStartY,
    required this.ghostSpeed,
    required this.frightenedSpeed,
    required this.frightenedMs,
    required this.scatterMs,
    required this.chaseMs,
    required this.releaseDotLimits,
  });

  int get width => layout.first.length;
  int get height => layout.length;

  int get doorY => houseY - 1;
  int get exitY => houseY - 2;
}

const List<LevelData> kLevels = [
  LevelData(
    name: 'Fácil',
    layout: [
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
      [1,3,2,2,2,2,2,1,2,2,2,2,2,3,1],
      [1,2,1,1,2,1,2,1,2,1,2,1,1,2,1],
      [1,2,2,2,2,2,2,2,2,2,2,2,2,2,1],
      [1,2,1,1,2,1,1,4,1,1,2,1,1,2,1],
      [1,2,2,2,2,1,0,0,0,1,2,2,2,2,1],
      [1,2,1,1,2,1,1,1,1,1,2,1,1,2,1],
      [1,2,2,2,2,2,2,0,2,2,2,2,2,2,1],
      [1,2,1,1,2,1,2,1,2,1,2,1,1,2,1],
      [1,3,2,2,2,2,2,1,2,2,2,2,2,3,1],
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
    ],
    houseX: 7,
    houseY: 5,
    pacStartX: 7,
    pacStartY: 7,
    ghostSpeed: 0.04,
    frightenedSpeed: 0.028,
    frightenedMs: 6000,
    scatterMs: 5000,
    chaseMs: 15000,
    releaseDotLimits: [0, 0, 8, 12],
  ),

  LevelData(
    name: 'Medio',
    layout: [
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
      [1,3,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,3,1],
      [1,2,1,1,2,1,1,2,2,1,2,2,1,1,2,1,1,2,1],
      [1,2,2,1,2,1,2,2,2,2,2,2,2,1,2,1,2,2,1],
      [1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1],
      [1,2,1,1,2,1,2,1,1,4,1,1,2,1,2,1,1,2,1],
      [1,2,2,2,2,1,2,1,0,0,0,1,2,1,2,2,2,2,1],
      [1,2,1,1,2,1,2,1,1,1,1,1,2,1,2,1,1,2,1],
      [1,2,2,2,2,2,2,2,2,0,2,2,2,2,2,2,2,2,1],
      [1,2,1,1,2,1,2,1,1,1,1,1,2,1,2,1,1,2,1],
      [1,2,2,1,2,1,2,2,2,2,2,2,2,1,2,1,2,2,1],
      [1,3,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,3,1],
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
    ],
    houseX: 9,
    houseY: 6,
    pacStartX: 9,
    pacStartY: 8,
    ghostSpeed: 0.044,
    frightenedSpeed: 0.030,
    frightenedMs: 4500,
    scatterMs: 4000,
    chaseMs: 20000,
    releaseDotLimits: [0, 0, 8, 12],
  ),

  LevelData(
    name: 'Difícil',
    layout: [
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
      [1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1],
      [1,2,1,1,2,1,1,1,2,1,1,2,1,1,2,1,1,1,2,1,1,2,1],
      [1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1],
      [1,2,1,1,1,1,2,1,1,1,2,1,2,1,1,1,2,1,1,1,1,2,1],
      [1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1],
      [1,2,1,1,1,2,1,1,2,1,1,4,1,1,2,1,1,2,1,1,1,2,1],
      [1,2,2,2,2,2,2,2,2,1,0,0,0,1,2,2,2,2,2,2,2,2,1],
      [1,2,1,2,1,1,1,1,2,1,1,1,1,1,2,1,1,1,1,2,1,2,1],
      [1,2,2,2,2,2,2,2,2,2,2,0,2,2,2,2,2,2,2,2,2,2,1],
      [1,2,1,1,1,1,2,1,1,2,1,1,1,2,1,1,2,1,1,1,1,2,1],
      [1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1],
      [1,2,1,1,2,1,1,1,2,1,1,2,1,1,2,1,1,1,2,1,1,2,1],
      [1,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1],
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
    ],
    houseX: 11,
    houseY: 7,
    pacStartX: 11,
    pacStartY: 9,
    ghostSpeed: 0.048,
    frightenedSpeed: 0.032,
    frightenedMs: 3200,
    scatterMs: 2500,
    chaseMs: 25000,
    releaseDotLimits: [0, 0, 4, 6],
  ),
];