import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @navHome.
  ///
  /// In ru, this message translates to:
  /// **'Главный'**
  String get navHome;

  /// No description provided for @navCalendar.
  ///
  /// In ru, this message translates to:
  /// **'Календарь'**
  String get navCalendar;

  /// No description provided for @navTasks.
  ///
  /// In ru, this message translates to:
  /// **'Задачи'**
  String get navTasks;

  /// No description provided for @navAssistant.
  ///
  /// In ru, this message translates to:
  /// **'Ассистент'**
  String get navAssistant;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @noConnectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи с сервером'**
  String get noConnectionTitle;

  /// No description provided for @noConnectionSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте интернет и попробуйте ещё раз'**
  String get noConnectionSubtitle;

  /// No description provided for @commonCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get commonDelete;

  /// No description provided for @commonAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get commonAdd;

  /// No description provided for @commonRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get commonRetry;

  /// No description provided for @pullToRetry.
  ///
  /// In ru, this message translates to:
  /// **'Потяните экран вниз, чтобы попробовать ещё раз'**
  String get pullToRetry;

  /// No description provided for @profileLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить профиль'**
  String get profileLoadError;

  /// No description provided for @profileEdit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать профиль'**
  String get profileEdit;

  /// No description provided for @profileStatCompleted.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{задача выполнена} few{задачи выполнено} many{задач выполнено} other{задачи выполнено}}\nза неделю'**
  String profileStatCompleted(int count);

  /// No description provided for @profileStatStreak.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{день} few{дня} many{дней} other{дня}}\nподряд'**
  String profileStatStreak(int count);

  /// No description provided for @profileStatActive.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{активный\nпроект} few{активных\nпроекта} many{активных\nпроектов} other{активного\nпроекта}}'**
  String profileStatActive(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'НАСТРОЙКИ'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In ru, this message translates to:
  /// **'Тема оформления'**
  String get settingsTheme;

  /// No description provided for @settingsNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get settingsNotifications;

  /// No description provided for @notificationsOn.
  ///
  /// In ru, this message translates to:
  /// **'Включены'**
  String get notificationsOn;

  /// No description provided for @notificationsOff.
  ///
  /// In ru, this message translates to:
  /// **'Выключены'**
  String get notificationsOff;

  /// No description provided for @settingsLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык интерфейса'**
  String get settingsLanguage;

  /// No description provided for @settingsAbout.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get settingsAbout;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта'**
  String get logout;

  /// No description provided for @remindersOnTitle.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания включены'**
  String get remindersOnTitle;

  /// No description provided for @remindersOnSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'За 15 минут до начала, а дела без времени — в 9:00'**
  String get remindersOnSubtitle;

  /// No description provided for @remindersOnWebSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Они приходят в мобильном приложении Zenda'**
  String get remindersOnWebSubtitle;

  /// No description provided for @remindersPermissionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нет разрешения на уведомления'**
  String get remindersPermissionTitle;

  /// No description provided for @remindersPermissionSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Разрешите уведомления для Zenda в настройках телефона'**
  String get remindersPermissionSubtitle;

  /// No description provided for @remindersOffTitle.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания выключены'**
  String get remindersOffTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In ru, this message translates to:
  /// **'Планировщик проектов, задач и событий с ИИ-ассистентом, который отвечает по вашим данным.'**
  String get aboutDescription;

  /// No description provided for @aboutVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version}'**
  String aboutVersion(String version);

  /// No description provided for @languageSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить язык'**
  String get languageSaveError;

  /// No description provided for @authSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get authSignUp;

  /// No description provided for @authWelcomeBack.
  ///
  /// In ru, this message translates to:
  /// **'С возвращением'**
  String get authWelcomeBack;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы продолжить'**
  String get authSignInSubtitle;

  /// No description provided for @fieldEmail.
  ///
  /// In ru, this message translates to:
  /// **'EMAIL'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In ru, this message translates to:
  /// **'ПАРОЛЬ'**
  String get fieldPassword;

  /// No description provided for @fieldConfirmPassword.
  ///
  /// In ru, this message translates to:
  /// **'ПОДТВЕРДИТЕ ПАРОЛЬ'**
  String get fieldConfirmPassword;

  /// No description provided for @fieldFirstName.
  ///
  /// In ru, this message translates to:
  /// **'ИМЯ'**
  String get fieldFirstName;

  /// No description provided for @fieldLastName.
  ///
  /// In ru, this message translates to:
  /// **'ФАМИЛИЯ'**
  String get fieldLastName;

  /// No description provided for @fieldRequired.
  ///
  /// In ru, this message translates to:
  /// **'Заполните это поле'**
  String get fieldRequired;

  /// No description provided for @hintEmail.
  ///
  /// In ru, this message translates to:
  /// **'arina@example.com'**
  String get hintEmail;

  /// No description provided for @hintFirstName.
  ///
  /// In ru, this message translates to:
  /// **'Арина'**
  String get hintFirstName;

  /// No description provided for @hintLastName.
  ///
  /// In ru, this message translates to:
  /// **'Гайсина'**
  String get hintLastName;

  /// No description provided for @authForgotLink.
  ///
  /// In ru, this message translates to:
  /// **'Я не помню пароль'**
  String get authForgotLink;

  /// No description provided for @authNoAccount.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта?'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт?'**
  String get authHaveAccount;

  /// No description provided for @authCheckData.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте данные и попробуйте ещё раз'**
  String get authCheckData;

  /// No description provided for @authCreateAccount.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get authCreateAccount;

  /// No description provided for @authCreateSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Это займёт меньше минуты'**
  String get authCreateSubtitle;

  /// No description provided for @passwordTooShort.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен быть не короче 8 символов'**
  String get passwordTooShort;

  /// No description provided for @passwordsMismatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get passwordsMismatch;

  /// No description provided for @forgotTitle.
  ///
  /// In ru, this message translates to:
  /// **'Восстановление пароля'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите почту — пришлём ссылку для сброса пароля'**
  String get forgotSubtitle;

  /// No description provided for @forgotSend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить письмо'**
  String get forgotSend;

  /// No description provided for @backToLogin.
  ///
  /// In ru, this message translates to:
  /// **'Вернуться ко входу'**
  String get backToLogin;

  /// No description provided for @forgotSentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Письмо отправлено'**
  String get forgotSentTitle;

  /// No description provided for @forgotSentBefore.
  ///
  /// In ru, this message translates to:
  /// **'Мы отправили ссылку для восстановления на '**
  String get forgotSentBefore;

  /// No description provided for @forgotSentAfter.
  ///
  /// In ru, this message translates to:
  /// **'. Проверьте почту и перейдите по ссылке.'**
  String get forgotSentAfter;

  /// No description provided for @forgotSendError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отправить письмо'**
  String get forgotSendError;

  /// No description provided for @forgotSendErrorSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте адрес и подключение к интернету'**
  String get forgotSendErrorSubtitle;

  /// No description provided for @greetingMorning.
  ///
  /// In ru, this message translates to:
  /// **'Доброе утро'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In ru, this message translates to:
  /// **'Добрый день'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In ru, this message translates to:
  /// **'Добрый вечер'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In ru, this message translates to:
  /// **'Доброй ночи'**
  String get greetingNight;

  /// No description provided for @greetingWithName.
  ///
  /// In ru, this message translates to:
  /// **'{greeting}, {name}'**
  String greetingWithName(String greeting, String name);

  /// No description provided for @sectionUrgent.
  ///
  /// In ru, this message translates to:
  /// **'ГОРЯЩИЕ ЗАДАЧИ'**
  String get sectionUrgent;

  /// No description provided for @sectionOtherProjects.
  ///
  /// In ru, this message translates to:
  /// **'ОСТАЛЬНЫЕ ПРОЕКТЫ'**
  String get sectionOtherProjects;

  /// No description provided for @sortByDeadline.
  ///
  /// In ru, this message translates to:
  /// **'По сроку'**
  String get sortByDeadline;

  /// No description provided for @sortNewest.
  ///
  /// In ru, this message translates to:
  /// **'Сначала новые'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In ru, this message translates to:
  /// **'Сначала старые'**
  String get sortOldest;

  /// No description provided for @sortByDeadlineFull.
  ///
  /// In ru, this message translates to:
  /// **'Сначала с ближайшим сроком'**
  String get sortByDeadlineFull;

  /// No description provided for @deadlineNone.
  ///
  /// In ru, this message translates to:
  /// **'Без срока'**
  String get deadlineNone;

  /// No description provided for @deadlineToday.
  ///
  /// In ru, this message translates to:
  /// **'Срок: сегодня'**
  String get deadlineToday;

  /// No description provided for @deadlineTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Срок: завтра'**
  String get deadlineTomorrow;

  /// No description provided for @deadlineDate.
  ///
  /// In ru, this message translates to:
  /// **'Срок: {date}'**
  String deadlineDate(String date);

  /// No description provided for @overdueDays.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Просрочено на {count} день} few{Просрочено на {count} дня} many{Просрочено на {count} дней} other{Просрочено на {count} дня}}'**
  String overdueDays(int count);

  /// No description provided for @tasksDoneOfTotal.
  ///
  /// In ru, this message translates to:
  /// **'{total, plural, one{{done} из {total} задачи} few{{done} из {total} задач} many{{done} из {total} задач} other{{done} из {total} задачи}}'**
  String tasksDoneOfTotal(int done, int total);

  /// No description provided for @tasksNone.
  ///
  /// In ru, this message translates to:
  /// **'задач пока нет'**
  String get tasksNone;

  /// No description provided for @statTotal.
  ///
  /// In ru, this message translates to:
  /// **'всего'**
  String get statTotal;

  /// No description provided for @statDone.
  ///
  /// In ru, this message translates to:
  /// **'выполнено'**
  String get statDone;

  /// No description provided for @statLeft.
  ///
  /// In ru, this message translates to:
  /// **'осталось'**
  String get statLeft;

  /// No description provided for @projectsLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить проекты'**
  String get projectsLoadError;

  /// No description provided for @projectsEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет проектов'**
  String get projectsEmptyTitle;

  /// No description provided for @projectsEmptyHome.
  ///
  /// In ru, this message translates to:
  /// **'Создайте первый проект — он появится здесь'**
  String get projectsEmptyHome;

  /// No description provided for @projectEdit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get projectEdit;

  /// No description provided for @projectAddTask.
  ///
  /// In ru, this message translates to:
  /// **'Задача'**
  String get projectAddTask;

  /// No description provided for @sectionTasks.
  ///
  /// In ru, this message translates to:
  /// **'ЗАДАЧИ'**
  String get sectionTasks;

  /// No description provided for @projectNoTasks.
  ///
  /// In ru, this message translates to:
  /// **'Задач пока нет — добавьте первую'**
  String get projectNoTasks;

  /// No description provided for @projectLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить проект'**
  String get projectLoadError;

  /// No description provided for @projectFinishedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Проект завершён'**
  String get projectFinishedTitle;

  /// No description provided for @projectFinishedArchived.
  ///
  /// In ru, this message translates to:
  /// **'Все задачи выполнены — проект находится в архиве'**
  String get projectFinishedArchived;

  /// No description provided for @projectFinishedMoved.
  ///
  /// In ru, this message translates to:
  /// **'Все задачи выполнены — проект перенесён в архив'**
  String get projectFinishedMoved;

  /// No description provided for @taskCompleteError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отметить задачу'**
  String get taskCompleteError;

  /// No description provided for @taskMetaToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get taskMetaToday;

  /// No description provided for @taskMetaYesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get taskMetaYesterday;

  /// No description provided for @taskMetaTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Завтра'**
  String get taskMetaTomorrow;

  /// No description provided for @taskMetaTomorrowAt.
  ///
  /// In ru, this message translates to:
  /// **'Завтра, {time}'**
  String taskMetaTomorrowAt(String time);

  /// No description provided for @projectFormEditTitle.
  ///
  /// In ru, this message translates to:
  /// **'Изменить проект'**
  String get projectFormEditTitle;

  /// No description provided for @projectFormNewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новый проект'**
  String get projectFormNewTitle;

  /// No description provided for @fieldName.
  ///
  /// In ru, this message translates to:
  /// **'НАЗВАНИЕ'**
  String get fieldName;

  /// No description provided for @projectNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, курсовая работа'**
  String get projectNameHint;

  /// No description provided for @fieldDeadline.
  ///
  /// In ru, this message translates to:
  /// **'СРОК'**
  String get fieldDeadline;

  /// No description provided for @projectDeadlineHelp.
  ///
  /// In ru, this message translates to:
  /// **'Проекты со сроком в ближайшие 7 дней попадают в «Горящие задачи»'**
  String get projectDeadlineHelp;

  /// No description provided for @projectCreate.
  ///
  /// In ru, this message translates to:
  /// **'Создать проект'**
  String get projectCreate;

  /// No description provided for @fieldNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите название'**
  String get fieldNameRequired;

  /// No description provided for @projectUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Проект обновлён'**
  String get projectUpdated;

  /// No description provided for @projectCreated.
  ///
  /// In ru, this message translates to:
  /// **'Проект создан'**
  String get projectCreated;

  /// No description provided for @projectSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить проект'**
  String get projectSaveError;

  /// No description provided for @projectCreateError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось создать проект'**
  String get projectCreateError;

  /// No description provided for @calendarAllDay.
  ///
  /// In ru, this message translates to:
  /// **'Весь день'**
  String get calendarAllDay;

  /// No description provided for @calendarCountToday.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} дело на сегодня} few{{count} дела на сегодня} many{{count} дел на сегодня} other{{count} дела на сегодня}}'**
  String calendarCountToday(int count);

  /// No description provided for @calendarCountDay.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} дело на этот день} few{{count} дела на этот день} many{{count} дел на этот день} other{{count} дела на этот день}}'**
  String calendarCountDay(int count);

  /// No description provided for @calendarEmptyToday.
  ///
  /// In ru, this message translates to:
  /// **'На сегодня ничего не запланировано'**
  String get calendarEmptyToday;

  /// No description provided for @calendarEmptyDay.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не запланировано'**
  String get calendarEmptyDay;

  /// No description provided for @calendarOverdueCount.
  ///
  /// In ru, this message translates to:
  /// **'просрочено: {count}'**
  String calendarOverdueCount(int count);

  /// No description provided for @sectionOverdue.
  ///
  /// In ru, this message translates to:
  /// **'ПРОСРОЧЕНО'**
  String get sectionOverdue;

  /// No description provided for @sectionSchedule.
  ///
  /// In ru, this message translates to:
  /// **'РАСПИСАНИЕ'**
  String get sectionSchedule;

  /// No description provided for @calendarTask.
  ///
  /// In ru, this message translates to:
  /// **'Задача'**
  String get calendarTask;

  /// No description provided for @calendarTaskWithProject.
  ///
  /// In ru, this message translates to:
  /// **'Задача · {project}'**
  String calendarTaskWithProject(String project);

  /// No description provided for @commentPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий: {text}'**
  String commentPrefix(String text);

  /// No description provided for @calendarLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить расписание'**
  String get calendarLoadError;

  /// No description provided for @calendarFreeDay.
  ///
  /// In ru, this message translates to:
  /// **'Свободный день'**
  String get calendarFreeDay;

  /// No description provided for @calendarFreeDayHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите «+», чтобы добавить событие'**
  String get calendarFreeDayHint;

  /// No description provided for @sheetTypeTask.
  ///
  /// In ru, this message translates to:
  /// **'ЗАДАЧА'**
  String get sheetTypeTask;

  /// No description provided for @sheetTypeEvent.
  ///
  /// In ru, this message translates to:
  /// **'СОБЫТИЕ'**
  String get sheetTypeEvent;

  /// No description provided for @sheetDone.
  ///
  /// In ru, this message translates to:
  /// **'Выполнена'**
  String get sheetDone;

  /// No description provided for @sheetAllDayLower.
  ///
  /// In ru, this message translates to:
  /// **'весь день'**
  String get sheetAllDayLower;

  /// No description provided for @sectionAttachments.
  ///
  /// In ru, this message translates to:
  /// **'ВЛОЖЕНИЯ'**
  String get sectionAttachments;

  /// No description provided for @attachmentsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Файлы и ссылки появятся здесь: видео, документы, полезные материалы.'**
  String get attachmentsEmpty;

  /// No description provided for @attachmentTypeVideo.
  ///
  /// In ru, this message translates to:
  /// **'Видео'**
  String get attachmentTypeVideo;

  /// No description provided for @attachmentTypeDocument.
  ///
  /// In ru, this message translates to:
  /// **'Документ'**
  String get attachmentTypeDocument;

  /// No description provided for @attachmentTypeFile.
  ///
  /// In ru, this message translates to:
  /// **'Файл'**
  String get attachmentTypeFile;

  /// No description provided for @attachmentTypeLink.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка'**
  String get attachmentTypeLink;

  /// No description provided for @attachmentFileHint.
  ///
  /// In ru, this message translates to:
  /// **'Документ, видео или картинка до 20 МБ'**
  String get attachmentFileHint;

  /// No description provided for @attachmentLinkHint.
  ///
  /// In ru, this message translates to:
  /// **'Видео на YouTube, статья, материалы'**
  String get attachmentLinkHint;

  /// No description provided for @attachmentOpenError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть вложение'**
  String get attachmentOpenError;

  /// No description provided for @attachmentTooBig.
  ///
  /// In ru, this message translates to:
  /// **'Файл слишком большой'**
  String get attachmentTooBig;

  /// No description provided for @attachmentTooBigHint.
  ///
  /// In ru, this message translates to:
  /// **'Можно прикрепить файл до 20 МБ'**
  String get attachmentTooBigHint;

  /// No description provided for @attachmentFileAdded.
  ///
  /// In ru, this message translates to:
  /// **'Файл прикреплён'**
  String get attachmentFileAdded;

  /// No description provided for @attachmentUploadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить файл'**
  String get attachmentUploadError;

  /// No description provided for @attachmentLinkAdded.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка добавлена'**
  String get attachmentLinkAdded;

  /// No description provided for @attachmentLinkError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось добавить ссылку'**
  String get attachmentLinkError;

  /// No description provided for @attachmentDeleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить вложение?'**
  String get attachmentDeleteTitle;

  /// No description provided for @attachmentDeleteText.
  ///
  /// In ru, this message translates to:
  /// **'«{label}» будет удалено.'**
  String attachmentDeleteText(String label);

  /// No description provided for @attachmentDeleteError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить вложение'**
  String get attachmentDeleteError;

  /// No description provided for @linkDialogNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Название (необязательно)'**
  String get linkDialogNameHint;

  /// No description provided for @linkDialogError.
  ///
  /// In ru, this message translates to:
  /// **'Вставьте ссылку, например youtube.com/…'**
  String get linkDialogError;

  /// No description provided for @sectionNotes.
  ///
  /// In ru, this message translates to:
  /// **'ЗАМЕТКИ'**
  String get sectionNotes;

  /// No description provided for @notesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет заметок. Сюда удобно записать детали, ссылки или мысли.'**
  String get notesEmpty;

  /// No description provided for @markDone.
  ///
  /// In ru, this message translates to:
  /// **'Отметить выполненной'**
  String get markDone;

  /// No description provided for @moveToToday.
  ///
  /// In ru, this message translates to:
  /// **'Перенести на сегодня'**
  String get moveToToday;

  /// No description provided for @taskCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Задача выполнена'**
  String get taskCompleted;

  /// No description provided for @movedToToday.
  ///
  /// In ru, this message translates to:
  /// **'Перенесено на сегодня'**
  String get movedToToday;

  /// No description provided for @moveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось перенести задачу'**
  String get moveError;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить задачу?'**
  String get deleteTaskTitle;

  /// No description provided for @deleteEventTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить событие?'**
  String get deleteEventTitle;

  /// No description provided for @deleteWithExtras.
  ///
  /// In ru, this message translates to:
  /// **'Заметки и вложения тоже удалятся. Это действие нельзя отменить.'**
  String get deleteWithExtras;

  /// No description provided for @deleteIrreversible.
  ///
  /// In ru, this message translates to:
  /// **'Это действие нельзя отменить.'**
  String get deleteIrreversible;

  /// No description provided for @taskDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Задача удалена'**
  String get taskDeleted;

  /// No description provided for @eventDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Событие удалено'**
  String get eventDeleted;

  /// No description provided for @deleteError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить'**
  String get deleteError;

  /// No description provided for @eventFormEditTitle.
  ///
  /// In ru, this message translates to:
  /// **'Изменить событие'**
  String get eventFormEditTitle;

  /// No description provided for @eventFormNewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новое событие'**
  String get eventFormNewTitle;

  /// No description provided for @eventTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, созвон с командой'**
  String get eventTitleHint;

  /// No description provided for @fieldDate.
  ///
  /// In ru, this message translates to:
  /// **'ДАТА'**
  String get fieldDate;

  /// No description provided for @fieldStart.
  ///
  /// In ru, this message translates to:
  /// **'НАЧАЛО'**
  String get fieldStart;

  /// No description provided for @fieldEnd.
  ///
  /// In ru, this message translates to:
  /// **'КОНЕЦ'**
  String get fieldEnd;

  /// No description provided for @fieldAddress.
  ///
  /// In ru, this message translates to:
  /// **'АДРЕС'**
  String get fieldAddress;

  /// No description provided for @fieldComment.
  ///
  /// In ru, this message translates to:
  /// **'КОММЕНТАРИЙ'**
  String get fieldComment;

  /// No description provided for @optionalHint.
  ///
  /// In ru, this message translates to:
  /// **'Необязательно'**
  String get optionalHint;

  /// No description provided for @startTimeRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите время начала'**
  String get startTimeRequired;

  /// No description provided for @endAfterStart.
  ///
  /// In ru, this message translates to:
  /// **'Конец должен быть позже начала'**
  String get endAfterStart;

  /// No description provided for @eventUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Событие обновлено'**
  String get eventUpdated;

  /// No description provided for @eventCreated.
  ///
  /// In ru, this message translates to:
  /// **'Событие создано'**
  String get eventCreated;

  /// No description provided for @eventSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить событие'**
  String get eventSaveError;

  /// No description provided for @eventCreateError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось создать событие'**
  String get eventCreateError;

  /// No description provided for @noteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get noteTitle;

  /// No description provided for @noteNewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новая заметка'**
  String get noteNewTitle;

  /// No description provided for @noteForTask.
  ///
  /// In ru, this message translates to:
  /// **'К задаче «{owner}»'**
  String noteForTask(String owner);

  /// No description provided for @noteForEvent.
  ///
  /// In ru, this message translates to:
  /// **'К событию «{owner}»'**
  String noteForEvent(String owner);

  /// No description provided for @fieldTitle.
  ///
  /// In ru, this message translates to:
  /// **'ЗАГОЛОВОК'**
  String get fieldTitle;

  /// No description provided for @fieldText.
  ///
  /// In ru, this message translates to:
  /// **'ТЕКСТ'**
  String get fieldText;

  /// No description provided for @noteHint.
  ///
  /// In ru, this message translates to:
  /// **'Детали, ссылки, мысли — всё, что важно не забыть'**
  String get noteHint;

  /// No description provided for @noteAssistantHint.
  ///
  /// In ru, this message translates to:
  /// **'Ассистент учитывает заметки, когда отвечает на вопросы'**
  String get noteAssistantHint;

  /// No description provided for @noteTextRequired.
  ///
  /// In ru, this message translates to:
  /// **'Напишите текст заметки'**
  String get noteTextRequired;

  /// No description provided for @noteSaved.
  ///
  /// In ru, this message translates to:
  /// **'Заметка сохранена'**
  String get noteSaved;

  /// No description provided for @noteSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить заметку'**
  String get noteSaveError;

  /// No description provided for @noteDeleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить заметку?'**
  String get noteDeleteTitle;

  /// No description provided for @noteDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Заметка удалена'**
  String get noteDeleted;

  /// No description provided for @noteDeleteError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить заметку'**
  String get noteDeleteError;

  /// No description provided for @tasksTitle.
  ///
  /// In ru, this message translates to:
  /// **'Все задачи'**
  String get tasksTitle;

  /// No description provided for @tasksSummary.
  ///
  /// In ru, this message translates to:
  /// **'{active, plural, one{{active} активная} few{{active} активные} many{{active} активных} other{{active} активной}} · {done} выполнено'**
  String tasksSummary(int active, int done);

  /// No description provided for @archiveTitle.
  ///
  /// In ru, this message translates to:
  /// **'Архив'**
  String get archiveTitle;

  /// No description provided for @tasksLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить задачи'**
  String get tasksLoadError;

  /// No description provided for @tasksEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите «+», чтобы создать первый проект'**
  String get tasksEmptyHint;

  /// No description provided for @tasksEmptyProject.
  ///
  /// In ru, this message translates to:
  /// **'Задач пока нет'**
  String get tasksEmptyProject;

  /// No description provided for @taskNewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новая задача'**
  String get taskNewTitle;

  /// No description provided for @createTaskSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'В одном из ваших проектов'**
  String get createTaskSubtitle;

  /// No description provided for @createProjectSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Со сроком или без'**
  String get createProjectSubtitle;

  /// No description provided for @createProjectFirst.
  ///
  /// In ru, this message translates to:
  /// **'Сначала создайте проект'**
  String get createProjectFirst;

  /// No description provided for @tasksLiveInProjects.
  ///
  /// In ru, this message translates to:
  /// **'Задачи живут внутри проектов'**
  String get tasksLiveInProjects;

  /// No description provided for @archiveCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} завершённый проект} few{{count} завершённых проекта} many{{count} завершённых проектов} other{{count} завершённого проекта}}'**
  String archiveCount(int count);

  /// No description provided for @archiveEmptySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет завершённых проектов'**
  String get archiveEmptySubtitle;

  /// No description provided for @archiveCompletedOn.
  ///
  /// In ru, this message translates to:
  /// **'Завершён {date}'**
  String archiveCompletedOn(String date);

  /// No description provided for @archiveCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Завершён'**
  String get archiveCompleted;

  /// No description provided for @restore.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить'**
  String get restore;

  /// No description provided for @projectRestored.
  ///
  /// In ru, this message translates to:
  /// **'Проект восстановлен'**
  String get projectRestored;

  /// No description provided for @restoreError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось восстановить проект'**
  String get restoreError;

  /// No description provided for @archiveNoTasks.
  ///
  /// In ru, this message translates to:
  /// **'Без задач'**
  String get archiveNoTasks;

  /// No description provided for @archiveLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить архив'**
  String get archiveLoadError;

  /// No description provided for @archiveEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Архив пуст'**
  String get archiveEmptyTitle;

  /// No description provided for @archiveEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Сюда попадают проекты, у которых выполнены все задачи'**
  String get archiveEmptyHint;

  /// No description provided for @taskFormEditTitle.
  ///
  /// In ru, this message translates to:
  /// **'Изменить задачу'**
  String get taskFormEditTitle;

  /// No description provided for @taskFormProject.
  ///
  /// In ru, this message translates to:
  /// **'Проект: {name}'**
  String taskFormProject(String name);

  /// No description provided for @fieldProject.
  ///
  /// In ru, this message translates to:
  /// **'ПРОЕКТ'**
  String get fieldProject;

  /// No description provided for @chooseProject.
  ///
  /// In ru, this message translates to:
  /// **'Выберите проект'**
  String get chooseProject;

  /// No description provided for @taskTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Что нужно сделать'**
  String get taskTitleHint;

  /// No description provided for @fieldTime.
  ///
  /// In ru, this message translates to:
  /// **'ВРЕМЯ'**
  String get fieldTime;

  /// No description provided for @setDeadlineFirst.
  ///
  /// In ru, this message translates to:
  /// **'Сначала укажите срок'**
  String get setDeadlineFirst;

  /// No description provided for @taskUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Задача обновлена'**
  String get taskUpdated;

  /// No description provided for @taskCreated.
  ///
  /// In ru, this message translates to:
  /// **'Задача создана'**
  String get taskCreated;

  /// No description provided for @taskSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить задачу'**
  String get taskSaveError;

  /// No description provided for @taskCreateError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось создать задачу'**
  String get taskCreateError;

  /// No description provided for @changePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Изменить фото'**
  String get changePhoto;

  /// No description provided for @fieldWorkplace.
  ///
  /// In ru, this message translates to:
  /// **'МЕСТО УЧЁБЫ ИЛИ РАБОТЫ'**
  String get fieldWorkplace;

  /// No description provided for @workplaceHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, 4 курс, Информационные системы'**
  String get workplaceHint;

  /// No description provided for @emailLabel.
  ///
  /// In ru, this message translates to:
  /// **'Email: {email}'**
  String emailLabel(String email);

  /// No description provided for @firstNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите имя'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите фамилию'**
  String get lastNameRequired;

  /// No description provided for @photoUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Фото обновлено'**
  String get photoUpdated;

  /// No description provided for @photoUploadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить фото'**
  String get photoUploadError;

  /// No description provided for @profileUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Профиль обновлён'**
  String get profileUpdated;

  /// No description provided for @profileSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить профиль'**
  String get profileSaveError;

  /// No description provided for @remindersChannel.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания'**
  String get remindersChannel;

  /// No description provided for @remindersChannelDescription.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания о задачах и событиях'**
  String get remindersChannelDescription;

  /// No description provided for @eventWord.
  ///
  /// In ru, this message translates to:
  /// **'Событие'**
  String get eventWord;

  /// No description provided for @reminderEventAt.
  ///
  /// In ru, this message translates to:
  /// **'Событие · начало в {time}'**
  String reminderEventAt(String time);

  /// No description provided for @reminderEventAllDay.
  ///
  /// In ru, this message translates to:
  /// **'Событие · сегодня, весь день'**
  String get reminderEventAllDay;

  /// No description provided for @reminderTaskAt.
  ///
  /// In ru, this message translates to:
  /// **'Задача · срок в {time}'**
  String reminderTaskAt(String time);

  /// No description provided for @reminderTaskToday.
  ///
  /// In ru, this message translates to:
  /// **'Задача · срок сегодня'**
  String get reminderTaskToday;

  /// No description provided for @assistantSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Отвечает на основе ваших задач и заметок'**
  String get assistantSubtitle;

  /// No description provided for @clearButton.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get clearButton;

  /// No description provided for @clearHistoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Очистить историю?'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryText.
  ///
  /// In ru, this message translates to:
  /// **'Вся переписка с ассистентом будет удалена.'**
  String get clearHistoryText;

  /// No description provided for @historyCleared.
  ///
  /// In ru, this message translates to:
  /// **'История очищена'**
  String get historyCleared;

  /// No description provided for @clearHistoryError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось очистить историю'**
  String get clearHistoryError;

  /// No description provided for @welcomeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чем помочь?'**
  String get welcomeTitle;

  /// No description provided for @welcomeText.
  ///
  /// In ru, this message translates to:
  /// **'Спросите о задачах, событиях или заметках — ассистент найдёт ответ в ваших данных'**
  String get welcomeText;

  /// No description provided for @suggestionToday.
  ///
  /// In ru, this message translates to:
  /// **'Что у меня сегодня?'**
  String get suggestionToday;

  /// No description provided for @suggestionUrgent.
  ///
  /// In ru, this message translates to:
  /// **'Какие проекты горят?'**
  String get suggestionUrgent;

  /// No description provided for @suggestionWeek.
  ///
  /// In ru, this message translates to:
  /// **'Собери итоги недели'**
  String get suggestionWeek;

  /// No description provided for @assistantCheckService.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте, что запущен rag_service и включён VPN'**
  String get assistantCheckService;

  /// No description provided for @assistantUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Ассистент сейчас недоступен'**
  String get assistantUnavailable;

  /// No description provided for @assistantNoAnswer.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить ответ'**
  String get assistantNoAnswer;

  /// No description provided for @assistantCouldNotAnswer.
  ///
  /// In ru, this message translates to:
  /// **'Ассистент не смог ответить'**
  String get assistantCouldNotAnswer;

  /// No description provided for @micDenied.
  ///
  /// In ru, this message translates to:
  /// **'Нет доступа к микрофону'**
  String get micDenied;

  /// No description provided for @micDeniedHint.
  ///
  /// In ru, this message translates to:
  /// **'Разрешите Zenda использовать микрофон'**
  String get micDeniedHint;

  /// No description provided for @recordStartError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось начать запись'**
  String get recordStartError;

  /// No description provided for @recordNotSaved.
  ///
  /// In ru, this message translates to:
  /// **'Запись не сохранилась'**
  String get recordNotSaved;

  /// No description provided for @recordTooShort.
  ///
  /// In ru, this message translates to:
  /// **'Слишком короткая запись'**
  String get recordTooShort;

  /// No description provided for @recordTooShortHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите микрофон, скажите вопрос и нажмите ещё раз'**
  String get recordTooShortHint;

  /// No description provided for @transcribeError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось распознать речь'**
  String get transcribeError;

  /// No description provided for @transcribeEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось разобрать слова'**
  String get transcribeEmpty;

  /// No description provided for @transcribeEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте сказать ещё раз чуть громче'**
  String get transcribeEmptyHint;

  /// No description provided for @recordingLabel.
  ///
  /// In ru, this message translates to:
  /// **'Запись · {time}'**
  String recordingLabel(String time);

  /// No description provided for @recordingHint.
  ///
  /// In ru, this message translates to:
  /// **'нажмите ■, чтобы закончить'**
  String get recordingHint;

  /// No description provided for @transcribing.
  ///
  /// In ru, this message translates to:
  /// **'Распознаю речь…'**
  String get transcribing;

  /// No description provided for @inputHint.
  ///
  /// In ru, this message translates to:
  /// **'Спросите что-нибудь...'**
  String get inputHint;

  /// No description provided for @sourceNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Этот источник уже удалён'**
  String get sourceNotFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
