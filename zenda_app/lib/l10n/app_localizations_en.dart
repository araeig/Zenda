// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navAssistant => 'Assistant';

  @override
  String get navProfile => 'Profile';

  @override
  String get noConnectionTitle => 'Can\'t reach the server';

  @override
  String get noConnectionSubtitle => 'Check your connection and try again';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonRetry => 'Retry';

  @override
  String get pullToRetry => 'Pull down to try again';

  @override
  String get profileLoadError => 'Couldn\'t load your profile';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String profileStatCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tasks done',
      one: 'task done',
    );
    return '$_temp0\nthis week';
  }

  @override
  String profileStatStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0\nin a row';
  }

  @override
  String profileStatActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'active\nprojects',
      one: 'active\nproject',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get notificationsOn => 'On';

  @override
  String get notificationsOff => 'Off';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAbout => 'About';

  @override
  String get logout => 'Log out';

  @override
  String get remindersOnTitle => 'Reminders on';

  @override
  String get remindersOnSubtitle =>
      '15 minutes before the start; items without a time at 9:00';

  @override
  String get remindersOnWebSubtitle => 'They arrive in the Zenda mobile app';

  @override
  String get remindersPermissionTitle => 'No notification permission';

  @override
  String get remindersPermissionSubtitle =>
      'Allow notifications for Zenda in your phone settings';

  @override
  String get remindersOffTitle => 'Reminders off';

  @override
  String get aboutDescription =>
      'A planner for projects, tasks and events with an AI assistant that answers from your own data.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get languageSaveError => 'Couldn\'t save the language';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authSignInSubtitle => 'Sign in to continue';

  @override
  String get fieldEmail => 'EMAIL';

  @override
  String get fieldPassword => 'PASSWORD';

  @override
  String get fieldConfirmPassword => 'CONFIRM PASSWORD';

  @override
  String get fieldFirstName => 'FIRST NAME';

  @override
  String get fieldLastName => 'LAST NAME';

  @override
  String get fieldRequired => 'Please fill in this field';

  @override
  String get hintEmail => 'name@example.com';

  @override
  String get hintFirstName => 'Alex';

  @override
  String get hintLastName => 'Smith';

  @override
  String get authForgotLink => 'I forgot my password';

  @override
  String get authNoAccount => 'No account?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authCheckData => 'Check your details and try again';

  @override
  String get authCreateAccount => 'Create an account';

  @override
  String get authCreateSubtitle => 'It takes less than a minute';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordsMismatch => 'Passwords don\'t match';

  @override
  String get forgotTitle => 'Password recovery';

  @override
  String get forgotSubtitle =>
      'Enter your email and we\'ll send you a reset link';

  @override
  String get forgotSend => 'Send email';

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get forgotSentTitle => 'Email sent';

  @override
  String get forgotSentBefore => 'We\'ve sent a recovery link to ';

  @override
  String get forgotSentAfter => '. Check your inbox and follow the link.';

  @override
  String get forgotSendError => 'Couldn\'t send the email';

  @override
  String get forgotSendErrorSubtitle =>
      'Check the address and your internet connection';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingNight => 'Good night';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get sectionUrgent => 'URGENT';

  @override
  String get sectionOtherProjects => 'OTHER PROJECTS';

  @override
  String get sortByDeadline => 'By deadline';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get sortByDeadlineFull => 'Nearest deadline first';

  @override
  String get deadlineNone => 'No deadline';

  @override
  String get deadlineToday => 'Due today';

  @override
  String get deadlineTomorrow => 'Due tomorrow';

  @override
  String deadlineDate(String date) {
    return 'Due $date';
  }

  @override
  String overdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Overdue by $count days',
      one: 'Overdue by $count day',
    );
    return '$_temp0';
  }

  @override
  String tasksDoneOfTotal(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$done of $total tasks',
      one: '$done of $total task',
    );
    return '$_temp0';
  }

  @override
  String get tasksNone => 'no tasks yet';

  @override
  String get statTotal => 'total';

  @override
  String get statDone => 'done';

  @override
  String get statLeft => 'left';

  @override
  String get projectsLoadError => 'Couldn\'t load projects';

  @override
  String get projectsEmptyTitle => 'No projects yet';

  @override
  String get projectsEmptyHome =>
      'Create your first project — it will appear here';

  @override
  String get projectEdit => 'Edit';

  @override
  String get projectAddTask => 'Task';

  @override
  String get sectionTasks => 'TASKS';

  @override
  String get projectNoTasks => 'No tasks yet — add the first one';

  @override
  String get projectLoadError => 'Couldn\'t load the project';

  @override
  String get projectFinishedTitle => 'Project completed';

  @override
  String get projectFinishedArchived =>
      'All tasks are done — the project is in the archive';

  @override
  String get projectFinishedMoved =>
      'All tasks are done — the project has moved to the archive';

  @override
  String get taskCompleteError => 'Couldn\'t mark the task';

  @override
  String get taskMetaToday => 'Today';

  @override
  String get taskMetaYesterday => 'Yesterday';

  @override
  String get taskMetaTomorrow => 'Tomorrow';

  @override
  String taskMetaTomorrowAt(String time) {
    return 'Tomorrow, $time';
  }

  @override
  String get projectFormEditTitle => 'Edit project';

  @override
  String get projectFormNewTitle => 'New project';

  @override
  String get fieldName => 'NAME';

  @override
  String get projectNameHint => 'For example, coursework';

  @override
  String get fieldDeadline => 'DEADLINE';

  @override
  String get projectDeadlineHelp =>
      'Projects due in the next 7 days appear in “Urgent”';

  @override
  String get projectCreate => 'Create project';

  @override
  String get fieldNameRequired => 'Enter a name';

  @override
  String get projectUpdated => 'Project updated';

  @override
  String get projectCreated => 'Project created';

  @override
  String get projectSaveError => 'Couldn\'t save the project';

  @override
  String get projectCreateError => 'Couldn\'t create the project';

  @override
  String get calendarAllDay => 'All day';

  @override
  String calendarCountToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items today',
      one: '$count item today',
    );
    return '$_temp0';
  }

  @override
  String calendarCountDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items this day',
      one: '$count item this day',
    );
    return '$_temp0';
  }

  @override
  String get calendarEmptyToday => 'Nothing planned for today';

  @override
  String get calendarEmptyDay => 'Nothing planned';

  @override
  String calendarOverdueCount(int count) {
    return 'overdue: $count';
  }

  @override
  String get sectionOverdue => 'OVERDUE';

  @override
  String get sectionSchedule => 'SCHEDULE';

  @override
  String get calendarTask => 'Task';

  @override
  String calendarTaskWithProject(String project) {
    return 'Task · $project';
  }

  @override
  String commentPrefix(String text) {
    return 'Comment: $text';
  }

  @override
  String get calendarLoadError => 'Couldn\'t load the schedule';

  @override
  String get calendarFreeDay => 'A free day';

  @override
  String get calendarFreeDayHint => 'Tap “+” to add an event';

  @override
  String get sheetTypeTask => 'TASK';

  @override
  String get sheetTypeEvent => 'EVENT';

  @override
  String get sheetDone => 'Completed';

  @override
  String get sheetAllDayLower => 'all day';

  @override
  String get sectionAttachments => 'ATTACHMENTS';

  @override
  String get attachmentsEmpty =>
      'Files and links will appear here: videos, documents, useful materials.';

  @override
  String get attachmentTypeVideo => 'Video';

  @override
  String get attachmentTypeDocument => 'Document';

  @override
  String get attachmentTypeFile => 'File';

  @override
  String get attachmentTypeLink => 'Link';

  @override
  String get attachmentFileHint => 'A document, video or image up to 20 MB';

  @override
  String get attachmentLinkHint => 'A YouTube video, an article, materials';

  @override
  String get attachmentOpenError => 'Couldn\'t open the attachment';

  @override
  String get attachmentTooBig => 'The file is too large';

  @override
  String get attachmentTooBigHint => 'You can attach files up to 20 MB';

  @override
  String get attachmentFileAdded => 'File attached';

  @override
  String get attachmentUploadError => 'Couldn\'t upload the file';

  @override
  String get attachmentLinkAdded => 'Link added';

  @override
  String get attachmentLinkError => 'Couldn\'t add the link';

  @override
  String get attachmentDeleteTitle => 'Delete attachment?';

  @override
  String attachmentDeleteText(String label) {
    return '“$label” will be deleted.';
  }

  @override
  String get attachmentDeleteError => 'Couldn\'t delete the attachment';

  @override
  String get linkDialogNameHint => 'Name (optional)';

  @override
  String get linkDialogError => 'Paste a link, for example youtube.com/…';

  @override
  String get sectionNotes => 'NOTES';

  @override
  String get notesEmpty =>
      'No notes yet. A good place for details, links or thoughts.';

  @override
  String get markDone => 'Mark as done';

  @override
  String get moveToToday => 'Move to today';

  @override
  String get taskCompleted => 'Task completed';

  @override
  String get movedToToday => 'Moved to today';

  @override
  String get moveError => 'Couldn\'t move the task';

  @override
  String get deleteTaskTitle => 'Delete task?';

  @override
  String get deleteEventTitle => 'Delete event?';

  @override
  String get deleteWithExtras =>
      'Notes and attachments will be deleted too. This can\'t be undone.';

  @override
  String get deleteIrreversible => 'This can\'t be undone.';

  @override
  String get taskDeleted => 'Task deleted';

  @override
  String get eventDeleted => 'Event deleted';

  @override
  String get deleteError => 'Couldn\'t delete';

  @override
  String get eventFormEditTitle => 'Edit event';

  @override
  String get eventFormNewTitle => 'New event';

  @override
  String get eventTitleHint => 'For example, a team call';

  @override
  String get fieldDate => 'DATE';

  @override
  String get fieldStart => 'START';

  @override
  String get fieldEnd => 'END';

  @override
  String get fieldAddress => 'ADDRESS';

  @override
  String get fieldComment => 'COMMENT';

  @override
  String get optionalHint => 'Optional';

  @override
  String get startTimeRequired => 'Choose a start time';

  @override
  String get endAfterStart => 'The end must be after the start';

  @override
  String get eventUpdated => 'Event updated';

  @override
  String get eventCreated => 'Event created';

  @override
  String get eventSaveError => 'Couldn\'t save the event';

  @override
  String get eventCreateError => 'Couldn\'t create the event';

  @override
  String get noteTitle => 'Note';

  @override
  String get noteNewTitle => 'New note';

  @override
  String noteForTask(String owner) {
    return 'For the task “$owner”';
  }

  @override
  String noteForEvent(String owner) {
    return 'For the event “$owner”';
  }

  @override
  String get fieldTitle => 'TITLE';

  @override
  String get fieldText => 'TEXT';

  @override
  String get noteHint =>
      'Details, links, thoughts — anything you shouldn\'t forget';

  @override
  String get noteAssistantHint =>
      'The assistant uses your notes when answering questions';

  @override
  String get noteTextRequired => 'Write the note text';

  @override
  String get noteSaved => 'Note saved';

  @override
  String get noteSaveError => 'Couldn\'t save the note';

  @override
  String get noteDeleteTitle => 'Delete note?';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String get noteDeleteError => 'Couldn\'t delete the note';

  @override
  String get tasksTitle => 'All tasks';

  @override
  String tasksSummary(int active, int done) {
    return '$active active · $done done';
  }

  @override
  String get archiveTitle => 'Archive';

  @override
  String get tasksLoadError => 'Couldn\'t load tasks';

  @override
  String get tasksEmptyHint => 'Tap “+” to create your first project';

  @override
  String get tasksEmptyProject => 'No tasks yet';

  @override
  String get taskNewTitle => 'New task';

  @override
  String get createTaskSubtitle => 'In one of your projects';

  @override
  String get createProjectSubtitle => 'With or without a deadline';

  @override
  String get createProjectFirst => 'Create a project first';

  @override
  String get tasksLiveInProjects => 'Tasks live inside projects';

  @override
  String archiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed projects',
      one: '$count completed project',
    );
    return '$_temp0';
  }

  @override
  String get archiveEmptySubtitle => 'No completed projects yet';

  @override
  String archiveCompletedOn(String date) {
    return 'Completed $date';
  }

  @override
  String get archiveCompleted => 'Completed';

  @override
  String get restore => 'Restore';

  @override
  String get projectRestored => 'Project restored';

  @override
  String get restoreError => 'Couldn\'t restore the project';

  @override
  String get archiveNoTasks => 'No tasks';

  @override
  String get archiveLoadError => 'Couldn\'t load the archive';

  @override
  String get archiveEmptyTitle => 'The archive is empty';

  @override
  String get archiveEmptyHint =>
      'Projects land here once all their tasks are done';

  @override
  String get taskFormEditTitle => 'Edit task';

  @override
  String taskFormProject(String name) {
    return 'Project: $name';
  }

  @override
  String get fieldProject => 'PROJECT';

  @override
  String get chooseProject => 'Choose a project';

  @override
  String get taskTitleHint => 'What needs to be done';

  @override
  String get fieldTime => 'TIME';

  @override
  String get setDeadlineFirst => 'Set a deadline first';

  @override
  String get taskUpdated => 'Task updated';

  @override
  String get taskCreated => 'Task created';

  @override
  String get taskSaveError => 'Couldn\'t save the task';

  @override
  String get taskCreateError => 'Couldn\'t create the task';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get fieldWorkplace => 'PLACE OF STUDY OR WORK';

  @override
  String get workplaceHint => 'For example, 4th year, Information Systems';

  @override
  String emailLabel(String email) {
    return 'Email: $email';
  }

  @override
  String get firstNameRequired => 'Enter your first name';

  @override
  String get lastNameRequired => 'Enter your last name';

  @override
  String get photoUpdated => 'Photo updated';

  @override
  String get photoUploadError => 'Couldn\'t upload the photo';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get profileSaveError => 'Couldn\'t save the profile';

  @override
  String get remindersChannel => 'Reminders';

  @override
  String get remindersChannelDescription => 'Reminders about tasks and events';

  @override
  String get eventWord => 'Event';

  @override
  String reminderEventAt(String time) {
    return 'Event · starts at $time';
  }

  @override
  String get reminderEventAllDay => 'Event · today, all day';

  @override
  String reminderTaskAt(String time) {
    return 'Task · due at $time';
  }

  @override
  String get reminderTaskToday => 'Task · due today';

  @override
  String get assistantSubtitle => 'Answers based on your tasks and notes';

  @override
  String get clearButton => 'Clear';

  @override
  String get clearHistoryTitle => 'Clear history?';

  @override
  String get clearHistoryText =>
      'Your whole conversation with the assistant will be deleted.';

  @override
  String get historyCleared => 'History cleared';

  @override
  String get clearHistoryError => 'Couldn\'t clear the history';

  @override
  String get welcomeTitle => 'How can I help?';

  @override
  String get welcomeText =>
      'Ask about your tasks, events or notes — the assistant will find the answer in your data';

  @override
  String get suggestionToday => 'What do I have today?';

  @override
  String get suggestionUrgent => 'Which projects are urgent?';

  @override
  String get suggestionWeek => 'Sum up my week';

  @override
  String get assistantCheckService =>
      'Make sure rag_service is running and the VPN is on';

  @override
  String get assistantUnavailable => 'The assistant is unavailable right now';

  @override
  String get assistantNoAnswer => 'Couldn\'t get an answer';

  @override
  String get assistantCouldNotAnswer => 'The assistant couldn\'t answer';

  @override
  String get micDenied => 'No access to the microphone';

  @override
  String get micDeniedHint => 'Allow Zenda to use the microphone';

  @override
  String get recordStartError => 'Couldn\'t start recording';

  @override
  String get recordNotSaved => 'The recording wasn\'t saved';

  @override
  String get recordTooShort => 'The recording is too short';

  @override
  String get recordTooShortHint =>
      'Tap the microphone, say your question and tap again';

  @override
  String get transcribeError => 'Couldn\'t recognize the speech';

  @override
  String get transcribeEmpty => 'Couldn\'t make out the words';

  @override
  String get transcribeEmptyHint => 'Try saying it again a little louder';

  @override
  String recordingLabel(String time) {
    return 'Recording · $time';
  }

  @override
  String get recordingHint => 'tap ■ to finish';

  @override
  String get transcribing => 'Recognizing speech…';

  @override
  String get inputHint => 'Ask something...';

  @override
  String get sourceNotFound => 'This source has been deleted';
}
