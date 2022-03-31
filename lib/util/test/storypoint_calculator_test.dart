import 'package:openroadmap/util/storypoint_calculator.dart';
import 'package:test/test.dart';

void main() {
  test('getDurationFromStoryPoints', () {
    expect(StoryPointCalculator.getDurationFromStoryPoints(100, 10, 10),
        equals(Duration(days: 100)));
  });

  test('getStoryPointDifference, 1 point per day', () {
    expect(
        StoryPointCalculator.getStoryPointDifference(
            DateTime(2022, 01, 01), DateTime(2022, 02, 01), 10, 10),
        equals(31));
  });

  test('getStoryPointDifference, 2 points per day', () {
    expect(
        StoryPointCalculator.getStoryPointDifference(
            DateTime(2022, 01, 01), DateTime(2022, 02, 01), 10, 20),
        equals(62));
  });
}
