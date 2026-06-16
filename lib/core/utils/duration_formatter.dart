class DurationFormatter {
  static String fromSeconds(int totalSeconds) {
    if (totalSeconds <= 0) return '0s';

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0 && seconds > 0) return '${hours}h ${seconds}s';
    if (hours > 0) return '${hours}h';
    if (minutes > 0 && seconds > 0) return '${minutes}m ${seconds}s';
    if (minutes > 0) return '${minutes}m';
    return '${seconds}s';
  }

  static String fromMinutes(int totalMinutes) {
    return fromSeconds(totalMinutes * 60);
  }
}
