using System.Globalization;

namespace ZendaAPI.UniversalMethods
{
    public static class Messages
    {
        private static readonly Dictionary<string, (string En, string Zh, string Ar)> Translations = new()
        {
            ["Успешно"] = ("Success", "成功", "تم بنجاح"),
            ["Обновлено"] = ("Updated", "已更新", "تم التحديث"),
            ["Удалено"] = ("Deleted", "已删除", "تم الحذف"),
            ["Нет токена авторизации"] = ("No authorization token", "缺少授权令牌", "رمز التفويض مفقود"),
            ["Сессия недействительна или истекла"] = ("Your session is invalid or has expired", "会话无效或已过期", "الجلسة غير صالحة أو منتهية"),

            ["Пользователь с таким email уже существует"] = ("A user with this email already exists", "该邮箱已被注册", "يوجد مستخدم بهذا البريد الإلكتروني بالفعل"),
            ["Неверный email или пароль"] = ("Wrong email or password", "邮箱或密码错误", "البريد الإلكتروني أو كلمة المرور غير صحيحة"),
            ["Пользователь не найден"] = ("User not found", "未找到用户", "المستخدم غير موجود"),
            ["Не удалось отправить письмо"] = ("Couldn't send the email", "邮件发送失败", "تعذّر إرسال الرسالة"),
            ["Если такой email зарегистрирован, письмо отправлено"] = ("If this email is registered, we've sent a message", "如果该邮箱已注册，邮件已发送", "إذا كان هذا البريد مسجلًا، فقد أُرسلت الرسالة"),
            ["Укажите имя"] = ("Enter your first name", "请输入名字", "أدخل الاسم"),
            ["Укажите фамилию"] = ("Enter your last name", "请输入姓氏", "أدخل اسم العائلة"),
            ["Укажите email"] = ("Enter your email", "请输入邮箱", "أدخل البريد الإلكتروني"),
            ["Некорректный email"] = ("Invalid email", "邮箱格式不正确", "بريد إلكتروني غير صالح"),
            ["Укажите пароль"] = ("Enter your password", "请输入密码", "أدخل كلمة المرور"),
            ["Пароль должен быть не короче 8 символов"] = ("Password must be at least 8 characters", "密码至少需要 8 个字符", "يجب ألا تقل كلمة المرور عن 8 أحرف"),
            ["Пароли не совпадают"] = ("Passwords don't match", "两次输入的密码不一致", "كلمتا المرور غير متطابقتين"),

            ["Проект не найден"] = ("Project not found", "未找到项目", "المشروع غير موجود"),
            ["Проект создан"] = ("Project created", "项目已创建", "تم إنشاء المشروع"),
            ["Проект восстановлен"] = ("Project restored", "项目已恢复", "تمت استعادة المشروع"),
            ["Укажите название проекта"] = ("Enter a project name", "请输入项目名称", "أدخل اسم المشروع"),
            ["Название не длиннее 200 символов"] = ("The name must be at most 200 characters", "名称不能超过 200 个字符", "يجب ألا يتجاوز الاسم 200 حرف"),

            ["Задача не найдена"] = ("Task not found", "未找到任务", "المهمة غير موجودة"),
            ["Задача создана"] = ("Task created", "任务已创建", "تم إنشاء المهمة"),
            ["Задача выполнена"] = ("Task completed", "任务已完成", "تم إنجاز المهمة"),
            ["Задача удалена"] = ("Task deleted", "任务已删除", "تم حذف المهمة"),
            ["Укажите название задачи"] = ("Enter a task title", "请输入任务名称", "أدخل عنوان المهمة"),
            ["Укажите корректный ProjectId"] = ("Choose a valid project", "请选择有效的项目", "اختر مشروعًا صالحًا"),
            ["Комментарий не длиннее 2000 символов"] = ("The comment must be at most 2000 characters", "备注不能超过 2000 个字符", "يجب ألا يتجاوز التعليق 2000 حرف"),
            ["Адрес не длиннее 300 символов"] = ("The address must be at most 300 characters", "地址不能超过 300 个字符", "يجب ألا يتجاوز العنوان 300 حرف"),

            ["Событие не найдено"] = ("Event not found", "未找到日程", "الحدث غير موجود"),
            ["Событие создано"] = ("Event created", "日程已创建", "تم إنشاء الحدث"),
            ["Укажите название события"] = ("Enter an event title", "请输入日程名称", "أدخل عنوان الحدث"),
            ["Укажите дату"] = ("Choose a date", "请选择日期", "اختر التاريخ"),
            ["Укажите время начала"] = ("Choose a start time", "请选择开始时间", "اختر وقت البدء"),

            ["Заметка не найдена"] = ("Note not found", "未找到笔记", "الملاحظة غير موجودة"),
            ["Заметка создана"] = ("Note created", "笔记已创建", "تم إنشاء الملاحظة"),
            ["Укажите заголовок"] = ("Enter a title", "请输入标题", "أدخل العنوان"),
            ["Заголовок не длиннее 200 символов"] = ("The title must be at most 200 characters", "标题不能超过 200 个字符", "يجب ألا يتجاوز العنوان 200 حرف"),
            ["Укажите содержание заметки"] = ("Write the note text", "请输入笔记内容", "اكتب نص الملاحظة"),
            ["Заметка не длиннее 5000 символов"] = ("The note must be at most 5000 characters", "笔记不能超过 5000 个字符", "يجب ألا تتجاوز الملاحظة 5000 حرف"),
            ["Задача или событие не найдены"] = ("Task or event not found", "未找到任务或日程", "المهمة أو الحدث غير موجود"),

            ["Укажите вопрос"] = ("Enter a question", "请输入问题", "أدخل سؤالًا"),
            ["Вопрос не длиннее 1000 символов"] = ("The question must be at most 1000 characters", "问题不能超过 1000 个字符", "يجب ألا يتجاوز السؤال 1000 حرف"),
            ["Вопрос должен быть от 1 до 1000 символов"] = ("The question must be 1 to 1000 characters long", "问题长度需在 1 到 1000 个字符之间", "يجب أن يتراوح طول السؤال بين 1 و1000 حرف"),
            ["Ассистент сейчас недоступен"] = ("The assistant is unavailable right now", "助手暂时不可用", "المساعد غير متاح حاليًا"),
            ["Ассистент не смог ответить"] = ("The assistant couldn't answer", "助手未能回答", "لم يتمكن المساعد من الإجابة"),
            ["История очищена"] = ("History cleared", "历史已清除", "تم مسح السجل"),
            ["Запись пустая"] = ("The recording is empty", "录音为空", "التسجيل فارغ"),
            ["Запись слишком длинная"] = ("The recording is too long", "录音太长", "التسجيل طويل جدًا"),
            ["Распознавание речи сейчас недоступно"] = ("Speech recognition is unavailable right now", "语音识别暂时不可用", "التعرّف على الكلام غير متاح حاليًا"),

            ["Профиль обновлён"] = ("Profile updated", "资料已更新", "تم تحديث الملف الشخصي"),
            ["Язык сохранён"] = ("Language saved", "语言已保存", "تم حفظ اللغة"),
            ["Неизвестный язык"] = ("Unknown language", "未知语言", "لغة غير معروفة"),
            ["Имя не длиннее 100 символов"] = ("The first name must be at most 100 characters", "名字不能超过 100 个字符", "يجب ألا يتجاوز الاسم 100 حرف"),
            ["Фамилия не длиннее 100 символов"] = ("The last name must be at most 100 characters", "姓氏不能超过 100 个字符", "يجب ألا يتجاوز اسم العائلة 100 حرف"),
            ["Место учёбы или работы — не длиннее 200 символов"] = ("Place of study or work must be at most 200 characters", "学校或单位不能超过 200 个字符", "يجب ألا يتجاوز مكان الدراسة أو العمل 200 حرف"),
            ["Файл не выбран"] = ("No file selected", "未选择文件", "لم يتم اختيار ملف"),
            ["Фото должно быть не больше 5 МБ"] = ("The photo must be 5 MB or less", "照片不能超过 5 MB", "يجب ألا يتجاوز حجم الصورة 5 ميغابايت"),
            ["Подходят только JPG, PNG и WEBP"] = ("Only JPG, PNG and WEBP are supported", "仅支持 JPG、PNG 和 WEBP", "الصيغ المدعومة: JPG وPNG وWEBP فقط"),
            ["Фото обновлено"] = ("Photo updated", "照片已更新", "تم تحديث الصورة"),

            ["Файл должен быть не больше 20 МБ"] = ("The file must be 20 MB or less", "文件不能超过 20 MB", "يجب ألا يتجاوز حجم الملف 20 ميغابايت"),
            ["Такой тип файла загружать нельзя"] = ("This file type can't be uploaded", "不能上传此类型的文件", "لا يمكن رفع هذا النوع من الملفات"),
            ["Вложение добавлено"] = ("Attachment added", "附件已添加", "تمت إضافة المرفق"),
            ["Ссылка добавлена"] = ("Link added", "链接已添加", "تمت إضافة الرابط"),
            ["Похоже, это не ссылка"] = ("This doesn't look like a link", "这看起来不像链接", "لا يبدو هذا رابطًا"),
            ["Вложение не найдено"] = ("Attachment not found", "未找到附件", "المرفق غير موجود"),
            ["Укажите ссылку"] = ("Enter a link", "请输入链接", "أدخل الرابط"),
            ["Ссылка слишком длинная"] = ("The link is too long", "链接太长", "الرابط طويل جدًا"),
            ["Название не длиннее 100 символов"] = ("The name must be at most 100 characters", "名称不能超过 100 个字符", "يجب ألا يتجاوز الاسم 100 حرف"),
        };

        public static string CurrentLanguage => CultureInfo.CurrentUICulture.TwoLetterISOLanguageName;

        public static string Translate(string? message, string? language = null)
        {
            if (string.IsNullOrEmpty(message)) return message ?? "";
            var lang = language ?? CurrentLanguage;
            if (lang == "ru" || !Translations.TryGetValue(message, out var t)) return message;
            return lang switch
            {
                "en" => t.En,
                "zh" => t.Zh,
                "ar" => t.Ar,
                _ => message
            };
        }
    }
}