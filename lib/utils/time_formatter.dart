String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds} s ago';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} d ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks w ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months mo ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years y ago';
  }
}
