class AppRoute {
  const AppRoute(this.name, this.path);

  final String name;
  final String path;
}

/// Central list of route names and paths.
class AppRoutes {
  const AppRoutes._();

  static const signIn = AppRoute('sign-in', '/sign-in');
  static const signUp = AppRoute('sign-up', '/sign-up');
  static const dashboard = AppRoute('dashboard', '/');
  static const courseLevel = AppRoute('course-level', '/level/:level');
  static const lesson = AppRoute('lesson', '/lesson/:lessonId');
  static const grammar = AppRoute('grammar', '/grammar');
  static const vocabulary = AppRoute('vocabulary', '/vocabulary');
  static const dictionary = AppRoute('dictionary', '/dictionary');
  static const verbs = AppRoute('verbs', '/verbs');
  static const reading = AppRoute('reading', '/reading');
  static const listening = AppRoute('listening', '/listening');
  static const writing = AppRoute('writing', '/writing');
  static const speaking = AppRoute('speaking', '/speaking');
  static const practice = AppRoute('practice', '/practice');
  static const assignments = AppRoute('assignments', '/assignments');
  static const teacher = AppRoute('teacher', '/teacher');
  static const progress = AppRoute('progress', '/progress');
  static const settings = AppRoute('settings', '/settings');
}
