class StoryPointCalculator {
  static Duration getDurationFromStoryPoints(
      num storyPoints, int sprintLengthInDays, int storyPointsPerSprint) {
    // Get duration per storypoint
    return Duration(
        days: ((storyPoints / storyPointsPerSprint) * sprintLengthInDays)
            .toInt());
  }

  // Story point difference is calculated as follows:
  // If the targetDate is after the calculated end date, story points remain
  // and can be spend on additional user stories.
  // If the targetDate is before the end date, the release contains to many
  // stories, and thus stories should be removed.
  // The resulting difference is converted into story points,
  // by dividing the story points per sprint by the sprint length in days,
  // resulting in the story points per day and multiplying this with the
  // days in the difference.
  static int getStoryPointDifference(DateTime targetDate, DateTime endDate,
      int sprintLengthInDays, int storyPointsPerSprint) {
    Duration difference;
    if (targetDate.isAfter(endDate)) {
      difference = targetDate.difference(endDate);
    } else {
      difference = endDate.difference(targetDate);
    }
    var storyPointsPerDay = storyPointsPerSprint / sprintLengthInDays;
    return (difference.inDays * storyPointsPerDay).toInt();
  }
}
