class ContestModel {
  final String banner; // 배너 사진 경로
  final String title;
  final DateTime contestStart;
  final DateTime contestEnd;

  ContestModel({
    required this.banner,
    required this.title,
    required this.contestStart,
    required this.contestEnd,
  });
}