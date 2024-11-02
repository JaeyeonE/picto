import 'package:picto/models/common/photo_section.dart';
import 'package:picto/models/liveboard/contest_model.dart';

class ContestInfoModel{
  final ContestModel contest;
  final List<PhotoSection> sections;

  ContestInfoModel({
    required this.contest,
    required this.sections,
  });
}