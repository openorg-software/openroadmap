class StoryPointCalculator {
  static Duration getDurationFromStoryPoints(
      num storyPoints, int sprintLengthInDays, int storyPointsPerSprint) {
    // Get duration per storypoint
    return Duration(
        days: ((storyPoints / storyPointsPerSprint) * sprintLengthInDays)
            .toInt());
  }

  static int getStoryPointDifference(DateTime targetDate, DateTime endDate,
      int sprintLengthInDays, int storyPointsPerSprint) {
    Duration difference;
    if (targetDate.isAfter(endDate)) {
      difference = targetDate.difference(endDate);
    } else {
      difference = endDate.difference(targetDate);
    }
    return (difference.inDays * (storyPointsPerSprint / sprintLengthInDays))
        .toInt();
  }
}
