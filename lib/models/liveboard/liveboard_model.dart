import '../common/photo_section.dart';

class LiveBoardModel{
  final String banner;
  final List<PhotoSection> recommandation;

  LiveBoardModel({
    required this.banner,
    required this.recommandation,
  });
}