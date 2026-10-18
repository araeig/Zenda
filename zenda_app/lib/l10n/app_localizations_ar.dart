// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCalendar => 'التقويم';

  @override
  String get navTasks => 'المهام';

  @override
  String get navAssistant => 'المساعد';

  @override
  String get navProfile => 'حسابي';

  @override
  String get noConnectionTitle => 'لا يوجد اتصال بالخادم';

  @override
  String get noConnectionSubtitle => 'تحقق من الإنترنت وحاول مرة أخرى';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get pullToRetry => 'اسحب الشاشة للأسفل لإعادة المحاولة';

  @override
  String get profileLoadError => 'تعذّر تحميل الملف الشخصي';

  @override
  String get profileEdit => 'تعديل الملف الشخصي';

  @override
  String profileStatCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مهمة منجزة',
      many: 'مهمة منجزة',
      few: 'مهام منجزة',
      two: 'مهمتان منجزتان',
      one: 'مهمة منجزة',
      zero: 'مهمة منجزة',
    );
    return '$_temp0\nهذا الأسبوع';
  }

  @override
  String profileStatStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يوم',
      many: 'يومًا',
      few: 'أيام',
      two: 'يومان',
      one: 'يوم',
      zero: 'يوم',
    );
    return '$_temp0\nعلى التوالي';
  }

  @override
  String profileStatActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مشروع\nنشط',
      many: 'مشروعًا\nنشطًا',
      few: 'مشاريع\nنشطة',
      two: 'مشروعان\nنشطان',
      one: 'مشروع\nنشط',
      zero: 'مشروع\nنشط',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get notificationsOn => 'مفعّلة';

  @override
  String get notificationsOff => 'متوقفة';

  @override
  String get settingsLanguage => 'لغة الواجهة';

  @override
  String get settingsAbout => 'حول التطبيق';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get remindersOnTitle => 'التذكيرات مفعّلة';

  @override
  String get remindersOnSubtitle =>
      'قبل البدء بـ 15 دقيقة، والمهام بلا وقت محدد في الساعة 9:00';

  @override
  String get remindersOnWebSubtitle =>
      'تصل التذكيرات في تطبيق Zenda على الهاتف';

  @override
  String get remindersPermissionTitle => 'لا يوجد إذن بالإشعارات';

  @override
  String get remindersPermissionSubtitle =>
      'اسمح لتطبيق Zenda بإرسال الإشعارات من إعدادات الهاتف';

  @override
  String get remindersOffTitle => 'التذكيرات متوقفة';

  @override
  String get aboutDescription =>
      'مخطِّط للمشاريع والمهام والأحداث مع مساعد ذكي يجيب بناءً على بياناتك.';

  @override
  String aboutVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get languageSaveError => 'تعذّر حفظ اللغة';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get authSignUp => 'إنشاء حساب';

  @override
  String get authWelcomeBack => 'مرحبًا بعودتك';

  @override
  String get authSignInSubtitle => 'سجّل الدخول للمتابعة';

  @override
  String get fieldEmail => 'البريد الإلكتروني';

  @override
  String get fieldPassword => 'كلمة المرور';

  @override
  String get fieldConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get fieldFirstName => 'الاسم';

  @override
  String get fieldLastName => 'اسم العائلة';

  @override
  String get fieldRequired => 'يرجى ملء هذا الحقل';

  @override
  String get hintEmail => 'name@example.com';

  @override
  String get hintFirstName => 'سارة';

  @override
  String get hintLastName => 'أحمد';

  @override
  String get authForgotLink => 'نسيت كلمة المرور';

  @override
  String get authNoAccount => 'ليس لديك حساب؟';

  @override
  String get authHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authCheckData => 'تحقق من البيانات وحاول مرة أخرى';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authCreateSubtitle => 'لن يستغرق ذلك أكثر من دقيقة';

  @override
  String get passwordTooShort => 'يجب ألا تقل كلمة المرور عن 8 أحرف';

  @override
  String get passwordsMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get forgotTitle => 'استعادة كلمة المرور';

  @override
  String get forgotSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور';

  @override
  String get forgotSend => 'إرسال الرسالة';

  @override
  String get backToLogin => 'العودة إلى تسجيل الدخول';

  @override
  String get forgotSentTitle => 'تم إرسال الرسالة';

  @override
  String get forgotSentBefore => 'أرسلنا رابط الاستعادة إلى ';

  @override
  String get forgotSentAfter => '. تحقق من بريدك واتبع الرابط.';

  @override
  String get forgotSendError => 'تعذّر إرسال الرسالة';

  @override
  String get forgotSendErrorSubtitle => 'تحقق من العنوان واتصالك بالإنترنت';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingAfternoon => 'نهارك سعيد';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get greetingNight => 'ليلة سعيدة';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting، $name';
  }

  @override
  String get sectionUrgent => 'عاجلة';

  @override
  String get sectionOtherProjects => 'مشاريع أخرى';

  @override
  String get sortByDeadline => 'حسب الموعد';

  @override
  String get sortNewest => 'الأحدث أولًا';

  @override
  String get sortOldest => 'الأقدم أولًا';

  @override
  String get sortByDeadlineFull => 'الأقرب موعدًا أولًا';

  @override
  String get deadlineNone => 'بلا موعد نهائي';

  @override
  String get deadlineToday => 'الموعد: اليوم';

  @override
  String get deadlineTomorrow => 'الموعد: غدًا';

  @override
  String deadlineDate(String date) {
    return 'الموعد: $date';
  }

  @override
  String overdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'متأخر بـ $count يوم',
      many: 'متأخر بـ $count يومًا',
      few: 'متأخر بـ $count أيام',
      two: 'متأخر بيومين',
      one: 'متأخر بيوم واحد',
      zero: 'متأخر',
    );
    return '$_temp0';
  }

  @override
  String tasksDoneOfTotal(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$done من $total مهمة',
      many: '$done من $total مهمة',
      few: '$done من $total مهام',
      two: '$done من مهمتين',
      one: '$done من مهمة واحدة',
      zero: 'لا توجد مهام',
    );
    return '$_temp0';
  }

  @override
  String get tasksNone => 'لا توجد مهام بعد';

  @override
  String get statTotal => 'الإجمالي';

  @override
  String get statDone => 'منجزة';

  @override
  String get statLeft => 'متبقية';

  @override
  String get projectsLoadError => 'تعذّر تحميل المشاريع';

  @override
  String get projectsEmptyTitle => 'لا توجد مشاريع بعد';

  @override
  String get projectsEmptyHome => 'أنشئ مشروعك الأول وسيظهر هنا';

  @override
  String get projectEdit => 'تعديل';

  @override
  String get projectAddTask => 'مهمة';

  @override
  String get sectionTasks => 'المهام';

  @override
  String get projectNoTasks => 'لا توجد مهام بعد — أضف أول مهمة';

  @override
  String get projectLoadError => 'تعذّر تحميل المشروع';

  @override
  String get projectFinishedTitle => 'اكتمل المشروع';

  @override
  String get projectFinishedArchived =>
      'اكتملت جميع المهام — المشروع في الأرشيف';

  @override
  String get projectFinishedMoved =>
      'اكتملت جميع المهام — نُقل المشروع إلى الأرشيف';

  @override
  String get taskCompleteError => 'تعذّر تحديد المهمة كمنجزة';

  @override
  String get taskMetaToday => 'اليوم';

  @override
  String get taskMetaYesterday => 'أمس';

  @override
  String get taskMetaTomorrow => 'غدًا';

  @override
  String taskMetaTomorrowAt(String time) {
    return 'غدًا، $time';
  }

  @override
  String get projectFormEditTitle => 'تعديل المشروع';

  @override
  String get projectFormNewTitle => 'مشروع جديد';

  @override
  String get fieldName => 'الاسم';

  @override
  String get projectNameHint => 'مثال: مشروع التخرج';

  @override
  String get fieldDeadline => 'الموعد النهائي';

  @override
  String get projectDeadlineHelp =>
      'المشاريع التي ينتهي موعدها خلال 7 أيام تظهر في «عاجلة»';

  @override
  String get projectCreate => 'إنشاء المشروع';

  @override
  String get fieldNameRequired => 'أدخل الاسم';

  @override
  String get projectUpdated => 'تم تحديث المشروع';

  @override
  String get projectCreated => 'تم إنشاء المشروع';

  @override
  String get projectSaveError => 'تعذّر حفظ المشروع';

  @override
  String get projectCreateError => 'تعذّر إنشاء المشروع';

  @override
  String get calendarAllDay => 'طوال اليوم';

  @override
  String calendarCountToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أمر اليوم',
      many: '$count أمرًا اليوم',
      few: '$count أمور اليوم',
      two: 'أمران اليوم',
      one: 'أمر واحد اليوم',
      zero: 'لا شيء اليوم',
    );
    return '$_temp0';
  }

  @override
  String calendarCountDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أمر في هذا اليوم',
      many: '$count أمرًا في هذا اليوم',
      few: '$count أمور في هذا اليوم',
      two: 'أمران في هذا اليوم',
      one: 'أمر واحد في هذا اليوم',
      zero: 'لا شيء في هذا اليوم',
    );
    return '$_temp0';
  }

  @override
  String get calendarEmptyToday => 'لا شيء مخطط لليوم';

  @override
  String get calendarEmptyDay => 'لا شيء مخطط';

  @override
  String calendarOverdueCount(int count) {
    return 'متأخرة: $count';
  }

  @override
  String get sectionOverdue => 'متأخرة';

  @override
  String get sectionSchedule => 'الجدول';

  @override
  String get calendarTask => 'مهمة';

  @override
  String calendarTaskWithProject(String project) {
    return 'مهمة · $project';
  }

  @override
  String commentPrefix(String text) {
    return 'تعليق: $text';
  }

  @override
  String get calendarLoadError => 'تعذّر تحميل الجدول';

  @override
  String get calendarFreeDay => 'يوم فارغ';

  @override
  String get calendarFreeDayHint => 'اضغط «+» لإضافة حدث';

  @override
  String get sheetTypeTask => 'مهمة';

  @override
  String get sheetTypeEvent => 'حدث';

  @override
  String get sheetDone => 'منجزة';

  @override
  String get sheetAllDayLower => 'طوال اليوم';

  @override
  String get sectionAttachments => 'المرفقات';

  @override
  String get attachmentsEmpty =>
      'ستظهر هنا الملفات والروابط: مقاطع فيديو ومستندات ومواد مفيدة.';

  @override
  String get attachmentTypeVideo => 'فيديو';

  @override
  String get attachmentTypeDocument => 'مستند';

  @override
  String get attachmentTypeFile => 'ملف';

  @override
  String get attachmentTypeLink => 'رابط';

  @override
  String get attachmentFileHint => 'مستند أو فيديو أو صورة حتى 20 ميغابايت';

  @override
  String get attachmentLinkHint => 'فيديو على YouTube أو مقال أو مواد';

  @override
  String get attachmentOpenError => 'تعذّر فتح المرفق';

  @override
  String get attachmentTooBig => 'الملف كبير جدًا';

  @override
  String get attachmentTooBigHint => 'يمكن إرفاق ملف حتى 20 ميغابايت';

  @override
  String get attachmentFileAdded => 'تم إرفاق الملف';

  @override
  String get attachmentUploadError => 'تعذّر رفع الملف';

  @override
  String get attachmentLinkAdded => 'تمت إضافة الرابط';

  @override
  String get attachmentLinkError => 'تعذّر إضافة الرابط';

  @override
  String get attachmentDeleteTitle => 'حذف المرفق؟';

  @override
  String attachmentDeleteText(String label) {
    return 'سيتم حذف «$label».';
  }

  @override
  String get attachmentDeleteError => 'تعذّر حذف المرفق';

  @override
  String get linkDialogNameHint => 'الاسم (اختياري)';

  @override
  String get linkDialogError => 'الصق رابطًا، مثل youtube.com/…';

  @override
  String get sectionNotes => 'الملاحظات';

  @override
  String get notesEmpty =>
      'لا توجد ملاحظات بعد. مكان مناسب لتدوين التفاصيل أو الروابط أو الأفكار.';

  @override
  String get markDone => 'تحديد كمنجزة';

  @override
  String get moveToToday => 'نقل إلى اليوم';

  @override
  String get taskCompleted => 'تم إنجاز المهمة';

  @override
  String get movedToToday => 'تم النقل إلى اليوم';

  @override
  String get moveError => 'تعذّر نقل المهمة';

  @override
  String get deleteTaskTitle => 'حذف المهمة؟';

  @override
  String get deleteEventTitle => 'حذف الحدث؟';

  @override
  String get deleteWithExtras =>
      'سيتم حذف الملاحظات والمرفقات أيضًا. لا يمكن التراجع عن ذلك.';

  @override
  String get deleteIrreversible => 'لا يمكن التراجع عن ذلك.';

  @override
  String get taskDeleted => 'تم حذف المهمة';

  @override
  String get eventDeleted => 'تم حذف الحدث';

  @override
  String get deleteError => 'تعذّر الحذف';

  @override
  String get eventFormEditTitle => 'تعديل الحدث';

  @override
  String get eventFormNewTitle => 'حدث جديد';

  @override
  String get eventTitleHint => 'مثال: مكالمة مع الفريق';

  @override
  String get fieldDate => 'التاريخ';

  @override
  String get fieldStart => 'البداية';

  @override
  String get fieldEnd => 'النهاية';

  @override
  String get fieldAddress => 'المكان';

  @override
  String get fieldComment => 'التعليق';

  @override
  String get optionalHint => 'اختياري';

  @override
  String get startTimeRequired => 'اختر وقت البدء';

  @override
  String get endAfterStart => 'يجب أن تكون النهاية بعد البداية';

  @override
  String get eventUpdated => 'تم تحديث الحدث';

  @override
  String get eventCreated => 'تم إنشاء الحدث';

  @override
  String get eventSaveError => 'تعذّر حفظ الحدث';

  @override
  String get eventCreateError => 'تعذّر إنشاء الحدث';

  @override
  String get noteTitle => 'ملاحظة';

  @override
  String get noteNewTitle => 'ملاحظة جديدة';

  @override
  String noteForTask(String owner) {
    return 'للمهمة «$owner»';
  }

  @override
  String noteForEvent(String owner) {
    return 'للحدث «$owner»';
  }

  @override
  String get fieldTitle => 'عنوان الملاحظة';

  @override
  String get fieldText => 'النص';

  @override
  String get noteHint => 'تفاصيل وروابط وأفكار — كل ما يجب ألا تنساه';

  @override
  String get noteAssistantHint =>
      'يستخدم المساعد ملاحظاتك عند الإجابة عن الأسئلة';

  @override
  String get noteTextRequired => 'اكتب نص الملاحظة';

  @override
  String get noteSaved => 'تم حفظ الملاحظة';

  @override
  String get noteSaveError => 'تعذّر حفظ الملاحظة';

  @override
  String get noteDeleteTitle => 'حذف الملاحظة؟';

  @override
  String get noteDeleted => 'تم حذف الملاحظة';

  @override
  String get noteDeleteError => 'تعذّر حذف الملاحظة';

  @override
  String get tasksTitle => 'كل المهام';

  @override
  String tasksSummary(int active, int done) {
    String _temp0 = intl.Intl.pluralLogic(
      active,
      locale: localeName,
      other: '$active مهمة نشطة',
      many: '$active مهمة نشطة',
      few: '$active مهام نشطة',
      two: 'مهمتان نشطتان',
      one: 'مهمة نشطة واحدة',
      zero: 'لا مهام نشطة',
    );
    return '$_temp0 · $done منجزة';
  }

  @override
  String get archiveTitle => 'الأرشيف';

  @override
  String get tasksLoadError => 'تعذّر تحميل المهام';

  @override
  String get tasksEmptyHint => 'اضغط «+» لإنشاء مشروعك الأول';

  @override
  String get tasksEmptyProject => 'لا توجد مهام بعد';

  @override
  String get taskNewTitle => 'مهمة جديدة';

  @override
  String get createTaskSubtitle => 'ضمن أحد مشاريعك';

  @override
  String get createProjectSubtitle => 'بموعد نهائي أو بدونه';

  @override
  String get createProjectFirst => 'أنشئ مشروعًا أولًا';

  @override
  String get tasksLiveInProjects => 'المهام تُنشأ داخل المشاريع';

  @override
  String archiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مشروع مكتمل',
      many: '$count مشروعًا مكتملًا',
      few: '$count مشاريع مكتملة',
      two: 'مشروعان مكتملان',
      one: 'مشروع مكتمل واحد',
      zero: 'لا مشاريع مكتملة',
    );
    return '$_temp0';
  }

  @override
  String get archiveEmptySubtitle => 'لا توجد مشاريع مكتملة بعد';

  @override
  String archiveCompletedOn(String date) {
    return 'اكتمل في $date';
  }

  @override
  String get archiveCompleted => 'مكتمل';

  @override
  String get restore => 'استعادة';

  @override
  String get projectRestored => 'تمت استعادة المشروع';

  @override
  String get restoreError => 'تعذّرت استعادة المشروع';

  @override
  String get archiveNoTasks => 'بلا مهام';

  @override
  String get archiveLoadError => 'تعذّر تحميل الأرشيف';

  @override
  String get archiveEmptyTitle => 'الأرشيف فارغ';

  @override
  String get archiveEmptyHint => 'تنتقل إلى هنا المشاريع التي أُنجزت كل مهامها';

  @override
  String get taskFormEditTitle => 'تعديل المهمة';

  @override
  String taskFormProject(String name) {
    return 'المشروع: $name';
  }

  @override
  String get fieldProject => 'المشروع';

  @override
  String get chooseProject => 'اختر مشروعًا';

  @override
  String get taskTitleHint => 'ما الذي يجب إنجازه';

  @override
  String get fieldTime => 'الوقت';

  @override
  String get setDeadlineFirst => 'حدّد الموعد أولًا';

  @override
  String get taskUpdated => 'تم تحديث المهمة';

  @override
  String get taskCreated => 'تم إنشاء المهمة';

  @override
  String get taskSaveError => 'تعذّر حفظ المهمة';

  @override
  String get taskCreateError => 'تعذّر إنشاء المهمة';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get fieldWorkplace => 'مكان الدراسة أو العمل';

  @override
  String get workplaceHint => 'مثال: السنة الرابعة، نظم المعلومات';

  @override
  String emailLabel(String email) {
    return 'البريد الإلكتروني: $email';
  }

  @override
  String get firstNameRequired => 'أدخل الاسم';

  @override
  String get lastNameRequired => 'أدخل اسم العائلة';

  @override
  String get photoUpdated => 'تم تحديث الصورة';

  @override
  String get photoUploadError => 'تعذّر رفع الصورة';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي';

  @override
  String get profileSaveError => 'تعذّر حفظ الملف الشخصي';

  @override
  String get remindersChannel => 'التذكيرات';

  @override
  String get remindersChannelDescription => 'تذكيرات بالمهام والأحداث';

  @override
  String get eventWord => 'حدث';

  @override
  String reminderEventAt(String time) {
    return 'حدث · يبدأ الساعة $time';
  }

  @override
  String get reminderEventAllDay => 'حدث · اليوم، طوال اليوم';

  @override
  String reminderTaskAt(String time) {
    return 'مهمة · الموعد الساعة $time';
  }

  @override
  String get reminderTaskToday => 'مهمة · الموعد اليوم';

  @override
  String get assistantSubtitle => 'يجيب بناءً على مهامك وملاحظاتك';

  @override
  String get clearButton => 'مسح';

  @override
  String get clearHistoryTitle => 'مسح السجل؟';

  @override
  String get clearHistoryText => 'سيتم حذف المحادثة كاملة مع المساعد.';

  @override
  String get historyCleared => 'تم مسح السجل';

  @override
  String get clearHistoryError => 'تعذّر مسح السجل';

  @override
  String get welcomeTitle => 'كيف يمكنني المساعدة؟';

  @override
  String get welcomeText =>
      'اسأل عن مهامك أو أحداثك أو ملاحظاتك وسيجد المساعد الإجابة في بياناتك';

  @override
  String get suggestionToday => 'ماذا لديّ اليوم؟';

  @override
  String get suggestionUrgent => 'ما المشاريع العاجلة؟';

  @override
  String get suggestionWeek => 'لخّص أسبوعي';

  @override
  String get assistantCheckService => 'تأكد من تشغيل rag_service وتفعيل VPN';

  @override
  String get assistantUnavailable => 'المساعد غير متاح حاليًا';

  @override
  String get assistantNoAnswer => 'تعذّر الحصول على إجابة';

  @override
  String get assistantCouldNotAnswer => 'لم يتمكن المساعد من الإجابة';

  @override
  String get micDenied => 'لا يوجد إذن بالوصول إلى الميكروفون';

  @override
  String get micDeniedHint => 'اسمح لتطبيق Zenda باستخدام الميكروفون';

  @override
  String get recordStartError => 'تعذّر بدء التسجيل';

  @override
  String get recordNotSaved => 'لم يُحفظ التسجيل';

  @override
  String get recordTooShort => 'التسجيل قصير جدًا';

  @override
  String get recordTooShortHint =>
      'اضغط على الميكروفون، وقل سؤالك، ثم اضغط مرة أخرى';

  @override
  String get transcribeError => 'تعذّر التعرّف على الكلام';

  @override
  String get transcribeEmpty => 'لم أتمكن من تمييز الكلمات';

  @override
  String get transcribeEmptyHint => 'حاول مرة أخرى بصوت أعلى قليلًا';

  @override
  String recordingLabel(String time) {
    return 'تسجيل · $time';
  }

  @override
  String get recordingHint => 'اضغط ■ للإنهاء';

  @override
  String get transcribing => 'جارٍ التعرّف على الكلام…';

  @override
  String get inputHint => 'اسأل أي شيء...';

  @override
  String get sourceNotFound => 'تم حذف هذا المصدر';
}
