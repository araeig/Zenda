// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get navHome => 'Главный';

  @override
  String get navCalendar => 'Календарь';

  @override
  String get navTasks => 'Задачи';

  @override
  String get navAssistant => 'Ассистент';

  @override
  String get navProfile => 'Профиль';

  @override
  String get noConnectionTitle => 'Нет связи с сервером';

  @override
  String get noConnectionSubtitle => 'Проверьте интернет и попробуйте ещё раз';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get pullToRetry => 'Потяните экран вниз, чтобы попробовать ещё раз';

  @override
  String get profileLoadError => 'Не удалось загрузить профиль';

  @override
  String get profileEdit => 'Редактировать профиль';

  @override
  String profileStatCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'задачи выполнено',
      many: 'задач выполнено',
      few: 'задачи выполнено',
      one: 'задача выполнена',
    );
    return '$_temp0\nза неделю';
  }

  @override
  String profileStatStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'дня',
      many: 'дней',
      few: 'дня',
      one: 'день',
    );
    return '$_temp0\nподряд';
  }

  @override
  String profileStatActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'активного\nпроекта',
      many: 'активных\nпроектов',
      few: 'активных\nпроекта',
      one: 'активный\nпроект',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'НАСТРОЙКИ';

  @override
  String get settingsTheme => 'Тема оформления';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get notificationsOn => 'Включены';

  @override
  String get notificationsOff => 'Выключены';

  @override
  String get settingsLanguage => 'Язык интерфейса';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get logout => 'Выйти из аккаунта';

  @override
  String get remindersOnTitle => 'Напоминания включены';

  @override
  String get remindersOnSubtitle =>
      'За 15 минут до начала, а дела без времени — в 9:00';

  @override
  String get remindersOnWebSubtitle =>
      'Они приходят в мобильном приложении Zenda';

  @override
  String get remindersPermissionTitle => 'Нет разрешения на уведомления';

  @override
  String get remindersPermissionSubtitle =>
      'Разрешите уведомления для Zenda в настройках телефона';

  @override
  String get remindersOffTitle => 'Напоминания выключены';

  @override
  String get aboutDescription =>
      'Планировщик проектов, задач и событий с ИИ-ассистентом, который отвечает по вашим данным.';

  @override
  String aboutVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get languageSaveError => 'Не удалось сохранить язык';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authSignUp => 'Зарегистрироваться';

  @override
  String get authWelcomeBack => 'С возвращением';

  @override
  String get authSignInSubtitle => 'Войдите, чтобы продолжить';

  @override
  String get fieldEmail => 'EMAIL';

  @override
  String get fieldPassword => 'ПАРОЛЬ';

  @override
  String get fieldConfirmPassword => 'ПОДТВЕРДИТЕ ПАРОЛЬ';

  @override
  String get fieldFirstName => 'ИМЯ';

  @override
  String get fieldLastName => 'ФАМИЛИЯ';

  @override
  String get fieldRequired => 'Заполните это поле';

  @override
  String get hintEmail => 'arina@example.com';

  @override
  String get hintFirstName => 'Арина';

  @override
  String get hintLastName => 'Гайсина';

  @override
  String get authForgotLink => 'Я не помню пароль';

  @override
  String get authNoAccount => 'Нет аккаунта?';

  @override
  String get authHaveAccount => 'Уже есть аккаунт?';

  @override
  String get authCheckData => 'Проверьте данные и попробуйте ещё раз';

  @override
  String get authCreateAccount => 'Создать аккаунт';

  @override
  String get authCreateSubtitle => 'Это займёт меньше минуты';

  @override
  String get passwordTooShort => 'Пароль должен быть не короче 8 символов';

  @override
  String get passwordsMismatch => 'Пароли не совпадают';

  @override
  String get forgotTitle => 'Восстановление пароля';

  @override
  String get forgotSubtitle =>
      'Введите почту — пришлём ссылку для сброса пароля';

  @override
  String get forgotSend => 'Отправить письмо';

  @override
  String get backToLogin => 'Вернуться ко входу';

  @override
  String get forgotSentTitle => 'Письмо отправлено';

  @override
  String get forgotSentBefore => 'Мы отправили ссылку для восстановления на ';

  @override
  String get forgotSentAfter => '. Проверьте почту и перейдите по ссылке.';

  @override
  String get forgotSendError => 'Не удалось отправить письмо';

  @override
  String get forgotSendErrorSubtitle =>
      'Проверьте адрес и подключение к интернету';

  @override
  String get greetingMorning => 'Доброе утро';

  @override
  String get greetingAfternoon => 'Добрый день';

  @override
  String get greetingEvening => 'Добрый вечер';

  @override
  String get greetingNight => 'Доброй ночи';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get sectionUrgent => 'ГОРЯЩИЕ ЗАДАЧИ';

  @override
  String get sectionOtherProjects => 'ОСТАЛЬНЫЕ ПРОЕКТЫ';

  @override
  String get sortByDeadline => 'По сроку';

  @override
  String get sortNewest => 'Сначала новые';

  @override
  String get sortOldest => 'Сначала старые';

  @override
  String get sortByDeadlineFull => 'Сначала с ближайшим сроком';

  @override
  String get deadlineNone => 'Без срока';

  @override
  String get deadlineToday => 'Срок: сегодня';

  @override
  String get deadlineTomorrow => 'Срок: завтра';

  @override
  String deadlineDate(String date) {
    return 'Срок: $date';
  }

  @override
  String overdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Просрочено на $count дня',
      many: 'Просрочено на $count дней',
      few: 'Просрочено на $count дня',
      one: 'Просрочено на $count день',
    );
    return '$_temp0';
  }

  @override
  String tasksDoneOfTotal(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$done из $total задачи',
      many: '$done из $total задач',
      few: '$done из $total задач',
      one: '$done из $total задачи',
    );
    return '$_temp0';
  }

  @override
  String get tasksNone => 'задач пока нет';

  @override
  String get statTotal => 'всего';

  @override
  String get statDone => 'выполнено';

  @override
  String get statLeft => 'осталось';

  @override
  String get projectsLoadError => 'Не удалось загрузить проекты';

  @override
  String get projectsEmptyTitle => 'Пока нет проектов';

  @override
  String get projectsEmptyHome => 'Создайте первый проект — он появится здесь';

  @override
  String get projectEdit => 'Изменить';

  @override
  String get projectAddTask => 'Задача';

  @override
  String get sectionTasks => 'ЗАДАЧИ';

  @override
  String get projectNoTasks => 'Задач пока нет — добавьте первую';

  @override
  String get projectLoadError => 'Не удалось загрузить проект';

  @override
  String get projectFinishedTitle => 'Проект завершён';

  @override
  String get projectFinishedArchived =>
      'Все задачи выполнены — проект находится в архиве';

  @override
  String get projectFinishedMoved =>
      'Все задачи выполнены — проект перенесён в архив';

  @override
  String get taskCompleteError => 'Не удалось отметить задачу';

  @override
  String get taskMetaToday => 'Сегодня';

  @override
  String get taskMetaYesterday => 'Вчера';

  @override
  String get taskMetaTomorrow => 'Завтра';

  @override
  String taskMetaTomorrowAt(String time) {
    return 'Завтра, $time';
  }

  @override
  String get projectFormEditTitle => 'Изменить проект';

  @override
  String get projectFormNewTitle => 'Новый проект';

  @override
  String get fieldName => 'НАЗВАНИЕ';

  @override
  String get projectNameHint => 'Например, курсовая работа';

  @override
  String get fieldDeadline => 'СРОК';

  @override
  String get projectDeadlineHelp =>
      'Проекты со сроком в ближайшие 7 дней попадают в «Горящие задачи»';

  @override
  String get projectCreate => 'Создать проект';

  @override
  String get fieldNameRequired => 'Укажите название';

  @override
  String get projectUpdated => 'Проект обновлён';

  @override
  String get projectCreated => 'Проект создан';

  @override
  String get projectSaveError => 'Не удалось сохранить проект';

  @override
  String get projectCreateError => 'Не удалось создать проект';

  @override
  String get calendarAllDay => 'Весь день';

  @override
  String calendarCountToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дела на сегодня',
      many: '$count дел на сегодня',
      few: '$count дела на сегодня',
      one: '$count дело на сегодня',
    );
    return '$_temp0';
  }

  @override
  String calendarCountDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дела на этот день',
      many: '$count дел на этот день',
      few: '$count дела на этот день',
      one: '$count дело на этот день',
    );
    return '$_temp0';
  }

  @override
  String get calendarEmptyToday => 'На сегодня ничего не запланировано';

  @override
  String get calendarEmptyDay => 'Ничего не запланировано';

  @override
  String calendarOverdueCount(int count) {
    return 'просрочено: $count';
  }

  @override
  String get sectionOverdue => 'ПРОСРОЧЕНО';

  @override
  String get sectionSchedule => 'РАСПИСАНИЕ';

  @override
  String get calendarTask => 'Задача';

  @override
  String calendarTaskWithProject(String project) {
    return 'Задача · $project';
  }

  @override
  String commentPrefix(String text) {
    return 'Комментарий: $text';
  }

  @override
  String get calendarLoadError => 'Не удалось загрузить расписание';

  @override
  String get calendarFreeDay => 'Свободный день';

  @override
  String get calendarFreeDayHint => 'Нажмите «+», чтобы добавить событие';

  @override
  String get sheetTypeTask => 'ЗАДАЧА';

  @override
  String get sheetTypeEvent => 'СОБЫТИЕ';

  @override
  String get sheetDone => 'Выполнена';

  @override
  String get sheetAllDayLower => 'весь день';

  @override
  String get sectionAttachments => 'ВЛОЖЕНИЯ';

  @override
  String get attachmentsEmpty =>
      'Файлы и ссылки появятся здесь: видео, документы, полезные материалы.';

  @override
  String get attachmentTypeVideo => 'Видео';

  @override
  String get attachmentTypeDocument => 'Документ';

  @override
  String get attachmentTypeFile => 'Файл';

  @override
  String get attachmentTypeLink => 'Ссылка';

  @override
  String get attachmentFileHint => 'Документ, видео или картинка до 20 МБ';

  @override
  String get attachmentLinkHint => 'Видео на YouTube, статья, материалы';

  @override
  String get attachmentOpenError => 'Не удалось открыть вложение';

  @override
  String get attachmentTooBig => 'Файл слишком большой';

  @override
  String get attachmentTooBigHint => 'Можно прикрепить файл до 20 МБ';

  @override
  String get attachmentFileAdded => 'Файл прикреплён';

  @override
  String get attachmentUploadError => 'Не удалось загрузить файл';

  @override
  String get attachmentLinkAdded => 'Ссылка добавлена';

  @override
  String get attachmentLinkError => 'Не удалось добавить ссылку';

  @override
  String get attachmentDeleteTitle => 'Удалить вложение?';

  @override
  String attachmentDeleteText(String label) {
    return '«$label» будет удалено.';
  }

  @override
  String get attachmentDeleteError => 'Не удалось удалить вложение';

  @override
  String get linkDialogNameHint => 'Название (необязательно)';

  @override
  String get linkDialogError => 'Вставьте ссылку, например youtube.com/…';

  @override
  String get sectionNotes => 'ЗАМЕТКИ';

  @override
  String get notesEmpty =>
      'Пока нет заметок. Сюда удобно записать детали, ссылки или мысли.';

  @override
  String get markDone => 'Отметить выполненной';

  @override
  String get moveToToday => 'Перенести на сегодня';

  @override
  String get taskCompleted => 'Задача выполнена';

  @override
  String get movedToToday => 'Перенесено на сегодня';

  @override
  String get moveError => 'Не удалось перенести задачу';

  @override
  String get deleteTaskTitle => 'Удалить задачу?';

  @override
  String get deleteEventTitle => 'Удалить событие?';

  @override
  String get deleteWithExtras =>
      'Заметки и вложения тоже удалятся. Это действие нельзя отменить.';

  @override
  String get deleteIrreversible => 'Это действие нельзя отменить.';

  @override
  String get taskDeleted => 'Задача удалена';

  @override
  String get eventDeleted => 'Событие удалено';

  @override
  String get deleteError => 'Не удалось удалить';

  @override
  String get eventFormEditTitle => 'Изменить событие';

  @override
  String get eventFormNewTitle => 'Новое событие';

  @override
  String get eventTitleHint => 'Например, созвон с командой';

  @override
  String get fieldDate => 'ДАТА';

  @override
  String get fieldStart => 'НАЧАЛО';

  @override
  String get fieldEnd => 'КОНЕЦ';

  @override
  String get fieldAddress => 'АДРЕС';

  @override
  String get fieldComment => 'КОММЕНТАРИЙ';

  @override
  String get optionalHint => 'Необязательно';

  @override
  String get startTimeRequired => 'Укажите время начала';

  @override
  String get endAfterStart => 'Конец должен быть позже начала';

  @override
  String get eventUpdated => 'Событие обновлено';

  @override
  String get eventCreated => 'Событие создано';

  @override
  String get eventSaveError => 'Не удалось сохранить событие';

  @override
  String get eventCreateError => 'Не удалось создать событие';

  @override
  String get noteTitle => 'Заметка';

  @override
  String get noteNewTitle => 'Новая заметка';

  @override
  String noteForTask(String owner) {
    return 'К задаче «$owner»';
  }

  @override
  String noteForEvent(String owner) {
    return 'К событию «$owner»';
  }

  @override
  String get fieldTitle => 'ЗАГОЛОВОК';

  @override
  String get fieldText => 'ТЕКСТ';

  @override
  String get noteHint => 'Детали, ссылки, мысли — всё, что важно не забыть';

  @override
  String get noteAssistantHint =>
      'Ассистент учитывает заметки, когда отвечает на вопросы';

  @override
  String get noteTextRequired => 'Напишите текст заметки';

  @override
  String get noteSaved => 'Заметка сохранена';

  @override
  String get noteSaveError => 'Не удалось сохранить заметку';

  @override
  String get noteDeleteTitle => 'Удалить заметку?';

  @override
  String get noteDeleted => 'Заметка удалена';

  @override
  String get noteDeleteError => 'Не удалось удалить заметку';

  @override
  String get tasksTitle => 'Все задачи';

  @override
  String tasksSummary(int active, int done) {
    String _temp0 = intl.Intl.pluralLogic(
      active,
      locale: localeName,
      other: '$active активной',
      many: '$active активных',
      few: '$active активные',
      one: '$active активная',
    );
    return '$_temp0 · $done выполнено';
  }

  @override
  String get archiveTitle => 'Архив';

  @override
  String get tasksLoadError => 'Не удалось загрузить задачи';

  @override
  String get tasksEmptyHint => 'Нажмите «+», чтобы создать первый проект';

  @override
  String get tasksEmptyProject => 'Задач пока нет';

  @override
  String get taskNewTitle => 'Новая задача';

  @override
  String get createTaskSubtitle => 'В одном из ваших проектов';

  @override
  String get createProjectSubtitle => 'Со сроком или без';

  @override
  String get createProjectFirst => 'Сначала создайте проект';

  @override
  String get tasksLiveInProjects => 'Задачи живут внутри проектов';

  @override
  String archiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count завершённого проекта',
      many: '$count завершённых проектов',
      few: '$count завершённых проекта',
      one: '$count завершённый проект',
    );
    return '$_temp0';
  }

  @override
  String get archiveEmptySubtitle => 'Пока нет завершённых проектов';

  @override
  String archiveCompletedOn(String date) {
    return 'Завершён $date';
  }

  @override
  String get archiveCompleted => 'Завершён';

  @override
  String get restore => 'Восстановить';

  @override
  String get projectRestored => 'Проект восстановлен';

  @override
  String get restoreError => 'Не удалось восстановить проект';

  @override
  String get archiveNoTasks => 'Без задач';

  @override
  String get archiveLoadError => 'Не удалось загрузить архив';

  @override
  String get archiveEmptyTitle => 'Архив пуст';

  @override
  String get archiveEmptyHint =>
      'Сюда попадают проекты, у которых выполнены все задачи';

  @override
  String get taskFormEditTitle => 'Изменить задачу';

  @override
  String taskFormProject(String name) {
    return 'Проект: $name';
  }

  @override
  String get fieldProject => 'ПРОЕКТ';

  @override
  String get chooseProject => 'Выберите проект';

  @override
  String get taskTitleHint => 'Что нужно сделать';

  @override
  String get fieldTime => 'ВРЕМЯ';

  @override
  String get setDeadlineFirst => 'Сначала укажите срок';

  @override
  String get taskUpdated => 'Задача обновлена';

  @override
  String get taskCreated => 'Задача создана';

  @override
  String get taskSaveError => 'Не удалось сохранить задачу';

  @override
  String get taskCreateError => 'Не удалось создать задачу';

  @override
  String get changePhoto => 'Изменить фото';

  @override
  String get fieldWorkplace => 'МЕСТО УЧЁБЫ ИЛИ РАБОТЫ';

  @override
  String get workplaceHint => 'Например, 4 курс, Информационные системы';

  @override
  String emailLabel(String email) {
    return 'Email: $email';
  }

  @override
  String get firstNameRequired => 'Укажите имя';

  @override
  String get lastNameRequired => 'Укажите фамилию';

  @override
  String get photoUpdated => 'Фото обновлено';

  @override
  String get photoUploadError => 'Не удалось загрузить фото';

  @override
  String get profileUpdated => 'Профиль обновлён';

  @override
  String get profileSaveError => 'Не удалось сохранить профиль';

  @override
  String get remindersChannel => 'Напоминания';

  @override
  String get remindersChannelDescription => 'Напоминания о задачах и событиях';

  @override
  String get eventWord => 'Событие';

  @override
  String reminderEventAt(String time) {
    return 'Событие · начало в $time';
  }

  @override
  String get reminderEventAllDay => 'Событие · сегодня, весь день';

  @override
  String reminderTaskAt(String time) {
    return 'Задача · срок в $time';
  }

  @override
  String get reminderTaskToday => 'Задача · срок сегодня';

  @override
  String get assistantSubtitle => 'Отвечает на основе ваших задач и заметок';

  @override
  String get clearButton => 'Очистить';

  @override
  String get clearHistoryTitle => 'Очистить историю?';

  @override
  String get clearHistoryText => 'Вся переписка с ассистентом будет удалена.';

  @override
  String get historyCleared => 'История очищена';

  @override
  String get clearHistoryError => 'Не удалось очистить историю';

  @override
  String get welcomeTitle => 'Чем помочь?';

  @override
  String get welcomeText =>
      'Спросите о задачах, событиях или заметках — ассистент найдёт ответ в ваших данных';

  @override
  String get suggestionToday => 'Что у меня сегодня?';

  @override
  String get suggestionUrgent => 'Какие проекты горят?';

  @override
  String get suggestionWeek => 'Собери итоги недели';

  @override
  String get assistantCheckService =>
      'Проверьте, что запущен rag_service и включён VPN';

  @override
  String get assistantUnavailable => 'Ассистент сейчас недоступен';

  @override
  String get assistantNoAnswer => 'Не удалось получить ответ';

  @override
  String get assistantCouldNotAnswer => 'Ассистент не смог ответить';

  @override
  String get micDenied => 'Нет доступа к микрофону';

  @override
  String get micDeniedHint => 'Разрешите Zenda использовать микрофон';

  @override
  String get recordStartError => 'Не удалось начать запись';

  @override
  String get recordNotSaved => 'Запись не сохранилась';

  @override
  String get recordTooShort => 'Слишком короткая запись';

  @override
  String get recordTooShortHint =>
      'Нажмите микрофон, скажите вопрос и нажмите ещё раз';

  @override
  String get transcribeError => 'Не удалось распознать речь';

  @override
  String get transcribeEmpty => 'Не получилось разобрать слова';

  @override
  String get transcribeEmptyHint => 'Попробуйте сказать ещё раз чуть громче';

  @override
  String recordingLabel(String time) {
    return 'Запись · $time';
  }

  @override
  String get recordingHint => 'нажмите ■, чтобы закончить';

  @override
  String get transcribing => 'Распознаю речь…';

  @override
  String get inputHint => 'Спросите что-нибудь...';

  @override
  String get sourceNotFound => 'Этот источник уже удалён';
}
