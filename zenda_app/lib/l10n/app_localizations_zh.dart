// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get navHome => '首页';

  @override
  String get navCalendar => '日历';

  @override
  String get navTasks => '任务';

  @override
  String get navAssistant => '助手';

  @override
  String get navProfile => '我的';

  @override
  String get noConnectionTitle => '无法连接服务器';

  @override
  String get noConnectionSubtitle => '请检查网络后重试';

  @override
  String get commonCancel => '取消';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonAdd => '添加';

  @override
  String get commonRetry => '重试';

  @override
  String get pullToRetry => '下拉屏幕重试';

  @override
  String get profileLoadError => '无法加载个人资料';

  @override
  String get profileEdit => '编辑资料';

  @override
  String profileStatCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '本周已完成\n的任务',
    );
    return '$_temp0';
  }

  @override
  String profileStatStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '连续打卡\n天数',
    );
    return '$_temp0';
  }

  @override
  String profileStatActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '进行中\n的项目',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsNotifications => '通知';

  @override
  String get notificationsOn => '已开启';

  @override
  String get notificationsOff => '已关闭';

  @override
  String get settingsLanguage => '界面语言';

  @override
  String get settingsAbout => '关于应用';

  @override
  String get logout => '退出登录';

  @override
  String get remindersOnTitle => '提醒已开启';

  @override
  String get remindersOnSubtitle => '开始前 15 分钟提醒，没有具体时间的事项在 9:00 提醒';

  @override
  String get remindersOnWebSubtitle => '提醒会在 Zenda 手机应用中送达';

  @override
  String get remindersPermissionTitle => '没有通知权限';

  @override
  String get remindersPermissionSubtitle => '请在手机设置中允许 Zenda 发送通知';

  @override
  String get remindersOffTitle => '提醒已关闭';

  @override
  String get aboutDescription => '集项目、任务和日程于一体的规划工具，配有根据你的数据回答问题的 AI 助手。';

  @override
  String aboutVersion(String version) {
    return '版本 $version';
  }

  @override
  String get languageSaveError => '无法保存语言';

  @override
  String get authSignIn => '登录';

  @override
  String get authSignUp => '注册';

  @override
  String get authWelcomeBack => '欢迎回来';

  @override
  String get authSignInSubtitle => '登录以继续';

  @override
  String get fieldEmail => '邮箱';

  @override
  String get fieldPassword => '密码';

  @override
  String get fieldConfirmPassword => '确认密码';

  @override
  String get fieldFirstName => '名字';

  @override
  String get fieldLastName => '姓氏';

  @override
  String get fieldRequired => '请填写此项';

  @override
  String get hintEmail => 'name@example.com';

  @override
  String get hintFirstName => '小明';

  @override
  String get hintLastName => '王';

  @override
  String get authForgotLink => '我忘记了密码';

  @override
  String get authNoAccount => '还没有账号？';

  @override
  String get authHaveAccount => '已有账号？';

  @override
  String get authCheckData => '请检查信息后重试';

  @override
  String get authCreateAccount => '创建账号';

  @override
  String get authCreateSubtitle => '不到一分钟即可完成';

  @override
  String get passwordTooShort => '密码至少需要 8 个字符';

  @override
  String get passwordsMismatch => '两次输入的密码不一致';

  @override
  String get forgotTitle => '找回密码';

  @override
  String get forgotSubtitle => '输入邮箱，我们会发送重置密码的链接';

  @override
  String get forgotSend => '发送邮件';

  @override
  String get backToLogin => '返回登录';

  @override
  String get forgotSentTitle => '邮件已发送';

  @override
  String get forgotSentBefore => '我们已将重置链接发送至 ';

  @override
  String get forgotSentAfter => '。请查收邮件并点击链接。';

  @override
  String get forgotSendError => '邮件发送失败';

  @override
  String get forgotSendErrorSubtitle => '请检查邮箱地址和网络连接';

  @override
  String get greetingMorning => '早上好';

  @override
  String get greetingAfternoon => '下午好';

  @override
  String get greetingEvening => '晚上好';

  @override
  String get greetingNight => '夜深了';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting，$name';
  }

  @override
  String get sectionUrgent => '紧急任务';

  @override
  String get sectionOtherProjects => '其他项目';

  @override
  String get sortByDeadline => '按截止日期';

  @override
  String get sortNewest => '最新优先';

  @override
  String get sortOldest => '最早优先';

  @override
  String get sortByDeadlineFull => '截止日期最近优先';

  @override
  String get deadlineNone => '无截止日期';

  @override
  String get deadlineToday => '今天截止';

  @override
  String get deadlineTomorrow => '明天截止';

  @override
  String deadlineDate(String date) {
    return '$date截止';
  }

  @override
  String overdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已逾期 $count 天',
    );
    return '$_temp0';
  }

  @override
  String tasksDoneOfTotal(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '已完成 $done/$total 项任务',
    );
    return '$_temp0';
  }

  @override
  String get tasksNone => '暂无任务';

  @override
  String get statTotal => '总计';

  @override
  String get statDone => '已完成';

  @override
  String get statLeft => '剩余';

  @override
  String get projectsLoadError => '无法加载项目';

  @override
  String get projectsEmptyTitle => '还没有项目';

  @override
  String get projectsEmptyHome => '创建第一个项目，它会显示在这里';

  @override
  String get projectEdit => '编辑';

  @override
  String get projectAddTask => '任务';

  @override
  String get sectionTasks => '任务';

  @override
  String get projectNoTasks => '还没有任务，添加第一个吧';

  @override
  String get projectLoadError => '无法加载项目';

  @override
  String get projectFinishedTitle => '项目已完成';

  @override
  String get projectFinishedArchived => '所有任务已完成，项目已归档';

  @override
  String get projectFinishedMoved => '所有任务已完成，项目已移至归档';

  @override
  String get taskCompleteError => '无法标记任务';

  @override
  String get taskMetaToday => '今天';

  @override
  String get taskMetaYesterday => '昨天';

  @override
  String get taskMetaTomorrow => '明天';

  @override
  String taskMetaTomorrowAt(String time) {
    return '明天 $time';
  }

  @override
  String get projectFormEditTitle => '编辑项目';

  @override
  String get projectFormNewTitle => '新建项目';

  @override
  String get fieldName => '名称';

  @override
  String get projectNameHint => '例如：课程设计';

  @override
  String get fieldDeadline => '截止日期';

  @override
  String get projectDeadlineHelp => '7 天内截止的项目会显示在“紧急任务”中';

  @override
  String get projectCreate => '创建项目';

  @override
  String get fieldNameRequired => '请输入名称';

  @override
  String get projectUpdated => '项目已更新';

  @override
  String get projectCreated => '项目已创建';

  @override
  String get projectSaveError => '无法保存项目';

  @override
  String get projectCreateError => '无法创建项目';

  @override
  String get calendarAllDay => '全天';

  @override
  String calendarCountToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今天有 $count 项安排',
    );
    return '$_temp0';
  }

  @override
  String calendarCountDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '这天有 $count 项安排',
    );
    return '$_temp0';
  }

  @override
  String get calendarEmptyToday => '今天没有安排';

  @override
  String get calendarEmptyDay => '没有安排';

  @override
  String calendarOverdueCount(int count) {
    return '已逾期：$count';
  }

  @override
  String get sectionOverdue => '已逾期';

  @override
  String get sectionSchedule => '日程';

  @override
  String get calendarTask => '任务';

  @override
  String calendarTaskWithProject(String project) {
    return '任务 · $project';
  }

  @override
  String commentPrefix(String text) {
    return '备注：$text';
  }

  @override
  String get calendarLoadError => '无法加载日程';

  @override
  String get calendarFreeDay => '空闲的一天';

  @override
  String get calendarFreeDayHint => '点击“+”添加日程';

  @override
  String get sheetTypeTask => '任务';

  @override
  String get sheetTypeEvent => '日程';

  @override
  String get sheetDone => '已完成';

  @override
  String get sheetAllDayLower => '全天';

  @override
  String get sectionAttachments => '附件';

  @override
  String get attachmentsEmpty => '文件和链接会显示在这里：视频、文档、实用资料。';

  @override
  String get attachmentTypeVideo => '视频';

  @override
  String get attachmentTypeDocument => '文档';

  @override
  String get attachmentTypeFile => '文件';

  @override
  String get attachmentTypeLink => '链接';

  @override
  String get attachmentFileHint => '文档、视频或图片，最大 20 MB';

  @override
  String get attachmentLinkHint => 'YouTube 视频、文章、资料';

  @override
  String get attachmentOpenError => '无法打开附件';

  @override
  String get attachmentTooBig => '文件太大';

  @override
  String get attachmentTooBigHint => '可附加不超过 20 MB 的文件';

  @override
  String get attachmentFileAdded => '文件已附加';

  @override
  String get attachmentUploadError => '无法上传文件';

  @override
  String get attachmentLinkAdded => '链接已添加';

  @override
  String get attachmentLinkError => '无法添加链接';

  @override
  String get attachmentDeleteTitle => '删除附件？';

  @override
  String attachmentDeleteText(String label) {
    return '“$label”将被删除。';
  }

  @override
  String get attachmentDeleteError => '无法删除附件';

  @override
  String get linkDialogNameHint => '名称（可选）';

  @override
  String get linkDialogError => '请粘贴链接，例如 youtube.com/…';

  @override
  String get sectionNotes => '笔记';

  @override
  String get notesEmpty => '还没有笔记。可以在这里记录细节、链接或想法。';

  @override
  String get markDone => '标记为已完成';

  @override
  String get moveToToday => '移到今天';

  @override
  String get taskCompleted => '任务已完成';

  @override
  String get movedToToday => '已移到今天';

  @override
  String get moveError => '无法移动任务';

  @override
  String get deleteTaskTitle => '删除任务？';

  @override
  String get deleteEventTitle => '删除日程？';

  @override
  String get deleteWithExtras => '笔记和附件也会被删除。此操作无法撤销。';

  @override
  String get deleteIrreversible => '此操作无法撤销。';

  @override
  String get taskDeleted => '任务已删除';

  @override
  String get eventDeleted => '日程已删除';

  @override
  String get deleteError => '删除失败';

  @override
  String get eventFormEditTitle => '编辑日程';

  @override
  String get eventFormNewTitle => '新建日程';

  @override
  String get eventTitleHint => '例如：团队会议';

  @override
  String get fieldDate => '日期';

  @override
  String get fieldStart => '开始';

  @override
  String get fieldEnd => '结束';

  @override
  String get fieldAddress => '地址';

  @override
  String get fieldComment => '备注';

  @override
  String get optionalHint => '可选';

  @override
  String get startTimeRequired => '请选择开始时间';

  @override
  String get endAfterStart => '结束时间必须晚于开始时间';

  @override
  String get eventUpdated => '日程已更新';

  @override
  String get eventCreated => '日程已创建';

  @override
  String get eventSaveError => '无法保存日程';

  @override
  String get eventCreateError => '无法创建日程';

  @override
  String get noteTitle => '笔记';

  @override
  String get noteNewTitle => '新建笔记';

  @override
  String noteForTask(String owner) {
    return '所属任务：“$owner”';
  }

  @override
  String noteForEvent(String owner) {
    return '所属日程：“$owner”';
  }

  @override
  String get fieldTitle => '标题';

  @override
  String get fieldText => '内容';

  @override
  String get noteHint => '细节、链接、想法——所有不能忘记的事';

  @override
  String get noteAssistantHint => '助手回答问题时会参考你的笔记';

  @override
  String get noteTextRequired => '请输入笔记内容';

  @override
  String get noteSaved => '笔记已保存';

  @override
  String get noteSaveError => '无法保存笔记';

  @override
  String get noteDeleteTitle => '删除笔记？';

  @override
  String get noteDeleted => '笔记已删除';

  @override
  String get noteDeleteError => '无法删除笔记';

  @override
  String get tasksTitle => '全部任务';

  @override
  String tasksSummary(int active, int done) {
    return '$active 项进行中 · $done 项已完成';
  }

  @override
  String get archiveTitle => '归档';

  @override
  String get tasksLoadError => '无法加载任务';

  @override
  String get tasksEmptyHint => '点击“+”创建第一个项目';

  @override
  String get tasksEmptyProject => '还没有任务';

  @override
  String get taskNewTitle => '新建任务';

  @override
  String get createTaskSubtitle => '放入你的某个项目';

  @override
  String get createProjectSubtitle => '可设置截止日期，也可不设置';

  @override
  String get createProjectFirst => '请先创建项目';

  @override
  String get tasksLiveInProjects => '任务需要放在项目中';

  @override
  String archiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个已完成项目',
    );
    return '$_temp0';
  }

  @override
  String get archiveEmptySubtitle => '还没有已完成的项目';

  @override
  String archiveCompletedOn(String date) {
    return '完成于 $date';
  }

  @override
  String get archiveCompleted => '已完成';

  @override
  String get restore => '恢复';

  @override
  String get projectRestored => '项目已恢复';

  @override
  String get restoreError => '无法恢复项目';

  @override
  String get archiveNoTasks => '没有任务';

  @override
  String get archiveLoadError => '无法加载归档';

  @override
  String get archiveEmptyTitle => '归档为空';

  @override
  String get archiveEmptyHint => '所有任务完成后，项目会移到这里';

  @override
  String get taskFormEditTitle => '编辑任务';

  @override
  String taskFormProject(String name) {
    return '项目：$name';
  }

  @override
  String get fieldProject => '项目';

  @override
  String get chooseProject => '请选择项目';

  @override
  String get taskTitleHint => '要做什么';

  @override
  String get fieldTime => '时间';

  @override
  String get setDeadlineFirst => '请先设置截止日期';

  @override
  String get taskUpdated => '任务已更新';

  @override
  String get taskCreated => '任务已创建';

  @override
  String get taskSaveError => '无法保存任务';

  @override
  String get taskCreateError => '无法创建任务';

  @override
  String get changePhoto => '更换照片';

  @override
  String get fieldWorkplace => '学校或单位';

  @override
  String get workplaceHint => '例如：大四，信息系统专业';

  @override
  String emailLabel(String email) {
    return '邮箱：$email';
  }

  @override
  String get firstNameRequired => '请输入名字';

  @override
  String get lastNameRequired => '请输入姓氏';

  @override
  String get photoUpdated => '照片已更新';

  @override
  String get photoUploadError => '无法上传照片';

  @override
  String get profileUpdated => '资料已更新';

  @override
  String get profileSaveError => '无法保存资料';

  @override
  String get remindersChannel => '提醒';

  @override
  String get remindersChannelDescription => '任务和日程提醒';

  @override
  String get eventWord => '日程';

  @override
  String reminderEventAt(String time) {
    return '日程 · $time 开始';
  }

  @override
  String get reminderEventAllDay => '日程 · 今天全天';

  @override
  String reminderTaskAt(String time) {
    return '任务 · $time 截止';
  }

  @override
  String get reminderTaskToday => '任务 · 今天截止';

  @override
  String get assistantSubtitle => '根据你的任务和笔记回答问题';

  @override
  String get clearButton => '清除';

  @override
  String get clearHistoryTitle => '清除历史记录？';

  @override
  String get clearHistoryText => '与助手的全部对话都将被删除。';

  @override
  String get historyCleared => '历史已清除';

  @override
  String get clearHistoryError => '无法清除历史记录';

  @override
  String get welcomeTitle => '需要什么帮助？';

  @override
  String get welcomeText => '询问你的任务、日程或笔记——助手会在你的数据中找到答案';

  @override
  String get suggestionToday => '我今天有什么安排？';

  @override
  String get suggestionUrgent => '哪些项目很紧急？';

  @override
  String get suggestionWeek => '总结一下这周';

  @override
  String get assistantCheckService => '请确认 rag_service 已启动且 VPN 已开启';

  @override
  String get assistantUnavailable => '助手暂时不可用';

  @override
  String get assistantNoAnswer => '无法获取回答';

  @override
  String get assistantCouldNotAnswer => '助手未能回答';

  @override
  String get micDenied => '无法使用麦克风';

  @override
  String get micDeniedHint => '请允许 Zenda 使用麦克风';

  @override
  String get recordStartError => '无法开始录音';

  @override
  String get recordNotSaved => '录音未保存';

  @override
  String get recordTooShort => '录音太短';

  @override
  String get recordTooShortHint => '点击麦克风，说出问题后再点一次';

  @override
  String get transcribeError => '无法识别语音';

  @override
  String get transcribeEmpty => '没有听清内容';

  @override
  String get transcribeEmptyHint => '请再说一遍，声音大一点';

  @override
  String recordingLabel(String time) {
    return '录音中 · $time';
  }

  @override
  String get recordingHint => '点击 ■ 结束';

  @override
  String get transcribing => '正在识别语音…';

  @override
  String get inputHint => '问点什么吧...';

  @override
  String get sourceNotFound => '该来源已被删除';
}
