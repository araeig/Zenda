using System.Net;

namespace ZendaAPI.UniversalMethods
{
    public static class ResetPasswordPages
    {
        private const string Moon = """<svg width="61" height="61" viewBox="0 0 61 61" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M30.5 60.5C47.0685 60.5 60.5 47.0685 60.5 30.5C60.5 13.9315 47.0685 0.5 30.5 0.5C13.9315 0.5 0.5 13.9315 0.5 30.5C0.5 47.0685 13.9315 60.5 30.5 60.5Z" fill="white" fill-opacity="0.55" stroke="white" stroke-opacity="0.65"/><path d="M40.25 31.3667C40.0774 33.2095 39.3839 34.9651 38.2504 36.4284C37.1169 37.8916 35.5903 39.002 33.8492 39.6297C32.108 40.2574 30.2241 40.3765 28.4176 39.9732C26.6112 39.5698 24.957 38.6606 23.6482 37.3518C22.3394 36.043 21.4302 34.3888 21.0268 32.5824C20.6235 30.776 20.7426 28.892 21.3703 27.1509C21.998 25.4097 23.1084 23.8831 24.5716 22.7496C26.0349 21.6162 27.7905 20.9226 29.6333 20.75C28.5381 22.2103 28.0063 24.0167 28.1357 25.8376C28.2652 27.6584 29.047 29.3715 30.3378 30.6622C31.6285 31.953 33.3416 32.7349 35.1624 32.8643C36.9833 32.9937 38.7897 32.4619 40.25 31.3667Z" stroke="#7B337E" stroke-width="1.79833" stroke-linecap="round" stroke-linejoin="round"/></svg>""";

        private static readonly Dictionary<string, Dictionary<string, string>> Texts = new()
        {
            ["ru"] = new()
            {
                ["formTitle"] = "Новый пароль",
                ["formSubtitle"] = "Придумайте новый пароль для входа в Zenda",
                ["labelNew"] = "НОВЫЙ ПАРОЛЬ",
                ["labelConfirm"] = "ПОДТВЕРДИТЕ ПАРОЛЬ",
                ["buttonSave"] = "Сохранить пароль",
                ["errorShort"] = "Пароль должен быть не короче 8 символов",
                ["errorMismatch"] = "Пароли не совпадают",
                ["invalidTitle"] = "Ссылка недействительна",
                ["invalidText"] = "Срок действия ссылки истёк или она уже использована. Запросите новое письмо в приложении.",
                ["doneTitle"] = "Пароль изменён",
                ["doneText"] = "Теперь войдите в приложении Zenda с новым паролем.",
                ["emailSubject"] = "Восстановление пароля Zenda",
                ["emailGreeting"] = "Здравствуйте, {0}!",
                ["emailText"] = "Вы запросили сброс пароля. Нажмите на кнопку, чтобы придумать новый. Ссылка действует 30 минут.",
                ["emailButton"] = "Сбросить пароль",
                ["emailNote"] = "Если вы не запрашивали сброс, просто проигнорируйте это письмо."
            },
            ["en"] = new()
            {
                ["formTitle"] = "New password",
                ["formSubtitle"] = "Create a new password to sign in to Zenda",
                ["labelNew"] = "NEW PASSWORD",
                ["labelConfirm"] = "CONFIRM PASSWORD",
                ["buttonSave"] = "Save password",
                ["errorShort"] = "Password must be at least 8 characters",
                ["errorMismatch"] = "Passwords don't match",
                ["invalidTitle"] = "This link is no longer valid",
                ["invalidText"] = "The link has expired or has already been used. Request a new email in the app.",
                ["doneTitle"] = "Password changed",
                ["doneText"] = "Now sign in to the Zenda app with your new password.",
                ["emailSubject"] = "Zenda password recovery",
                ["emailGreeting"] = "Hi, {0}!",
                ["emailText"] = "You requested a password reset. Press the button to create a new one. The link is valid for 30 minutes.",
                ["emailButton"] = "Reset password",
                ["emailNote"] = "If you didn't request a reset, just ignore this email."
            },
            ["zh"] = new()
            {
                ["formTitle"] = "设置新密码",
                ["formSubtitle"] = "为登录 Zenda 设置一个新密码",
                ["labelNew"] = "新密码",
                ["labelConfirm"] = "确认密码",
                ["buttonSave"] = "保存密码",
                ["errorShort"] = "密码至少需要 8 个字符",
                ["errorMismatch"] = "两次输入的密码不一致",
                ["invalidTitle"] = "链接已失效",
                ["invalidText"] = "该链接已过期或已被使用。请在应用中重新申请邮件。",
                ["doneTitle"] = "密码已修改",
                ["doneText"] = "现在请使用新密码登录 Zenda 应用。",
                ["emailSubject"] = "Zenda 密码找回",
                ["emailGreeting"] = "{0}，你好！",
                ["emailText"] = "你申请了重置密码。点击下方按钮设置新密码，链接 30 分钟内有效。",
                ["emailButton"] = "重置密码",
                ["emailNote"] = "如果不是你本人申请的，请忽略此邮件。"
            },
            ["ar"] = new()
            {
                ["formTitle"] = "كلمة مرور جديدة",
                ["formSubtitle"] = "أنشئ كلمة مرور جديدة لتسجيل الدخول إلى Zenda",
                ["labelNew"] = "كلمة المرور الجديدة",
                ["labelConfirm"] = "تأكيد كلمة المرور",
                ["buttonSave"] = "حفظ كلمة المرور",
                ["errorShort"] = "يجب ألا تقل كلمة المرور عن 8 أحرف",
                ["errorMismatch"] = "كلمتا المرور غير متطابقتين",
                ["invalidTitle"] = "الرابط غير صالح",
                ["invalidText"] = "انتهت صلاحية هذا الرابط أو تم استخدامه بالفعل. اطلب رسالة جديدة من التطبيق.",
                ["doneTitle"] = "تم تغيير كلمة المرور",
                ["doneText"] = "سجّل الدخول الآن إلى تطبيق Zenda بكلمة المرور الجديدة.",
                ["emailSubject"] = "استعادة كلمة المرور في Zenda",
                ["emailGreeting"] = "مرحبًا {0}!",
                ["emailText"] = "لقد طلبت إعادة تعيين كلمة المرور. اضغط على الزر لإنشاء كلمة مرور جديدة. الرابط صالح لمدة 30 دقيقة.",
                ["emailButton"] = "إعادة تعيين كلمة المرور",
                ["emailNote"] = "إذا لم تطلب إعادة التعيين، فتجاهل هذه الرسالة."
            }
        };

        public static string Lang(string? lang) => lang is "en" or "zh" or "ar" ? lang : "ru";

        public static string T(string key, string? lang) => Texts[Lang(lang)][key];

        private static string Dir(string lang) => lang == "ar" ? "rtl" : "ltr";

        private static string Layout(string content, string lang) => $$"""
            <!DOCTYPE html>
            <html lang="{{lang}}" dir="{{Dir(lang)}}">
            <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>Zenda</title>
            <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@500;700;800&display=swap" rel="stylesheet">
            <style>
            * { box-sizing: border-box; margin: 0; }
            body { min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 24px; font-family: 'Manrope', sans-serif; background: linear-gradient(135deg, #FDF1F6, #DCD9F2); overflow: hidden; position: relative; }
            .blob { position: absolute; border-radius: 50%; filter: blur(60px); opacity: .6; }
            .b1 { width: 260px; height: 260px; background: #F0C7DD; top: -60px; left: -60px; }
            .b2 { width: 220px; height: 220px; background: #A9ABDD; bottom: -40px; right: -50px; }
            .card { position: relative; width: 100%; max-width: 380px; padding: 36px 28px 28px; border-radius: 24px; background: rgba(255,255,255,.55); border: 1px solid rgba(255,255,255,.75); backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px); text-align: center; }
            h1 { margin: 20px 0 6px; font-size: 22px; font-weight: 800; color: #2A0A3D; }
            .sub { font-size: 13px; line-height: 1.5; color: #7A6486; }
            form { margin-top: 28px; text-align: start; }
            label { display: block; margin-bottom: 8px; font-size: 10px; font-weight: 700; letter-spacing: .5px; color: #7A6486; }
            input { width: 100%; height: 50px; margin-bottom: 16px; padding: 0 16px; border: none; border-radius: 14px; background: rgba(255,255,255,.6); font: 500 15px 'Manrope', sans-serif; color: #2A0A3D; outline: none; }
            input:focus { box-shadow: 0 0 0 1.5px #7B337E; }
            .error { margin: -4px 0 16px; font-size: 12px; color: #C2456B; }
            button { width: 100%; height: 50px; margin-top: 4px; border: none; border-radius: 16px; background: #7B337E; color: #FDF6FA; font: 700 14px 'Manrope', sans-serif; cursor: pointer; }
            </style>
            </head>
            <body>
            <div class="blob b1"></div>
            <div class="blob b2"></div>
            <div class="card">
            {{content}}
            </div>
            </body>
            </html>
            """;

        public static string Form(string token, string? error, string? lang)
        {
            var l = Lang(lang);
            var errorBlock = error == null ? "" : $"""<p class="error">{WebUtility.HtmlEncode(error)}</p>""";
            return Layout($$"""
                {{Moon}}
                <h1>{{T("formTitle", l)}}</h1>
                <p class="sub">{{T("formSubtitle", l)}}</p>
                <form method="post" action="/auth/reset-password">
                <input type="hidden" name="Token" value="{{WebUtility.HtmlEncode(token)}}">
                <input type="hidden" name="Lang" value="{{l}}">
                <label>{{T("labelNew", l)}}</label>
                <input type="password" name="Password" required minlength="8" placeholder="••••••••">
                <label>{{T("labelConfirm", l)}}</label>
                <input type="password" name="ConfirmPassword" required minlength="8" placeholder="••••••••">
                {{errorBlock}}
                <button type="submit">{{T("buttonSave", l)}}</button>
                </form>
                """, l);
        }

        public static string InvalidLink(string? lang)
        {
            var l = Lang(lang);
            return Result(T("invalidTitle", l), T("invalidText", l), l);
        }

        public static string Done(string? lang)
        {
            var l = Lang(lang);
            return Result(T("doneTitle", l), T("doneText", l), l);
        }

        private static string Result(string title, string text, string lang) => Layout($$"""
            {{Moon}}
            <h1>{{title}}</h1>
            <p class="sub">{{text}}</p>
            """, lang);

        public static Dictionary<string, string> EmailImages() => new()
        {
            ["logo-on-light"] = Path.Combine(AppContext.BaseDirectory, "Assets", "Email", "logo_on_light.png"),
            ["logo-on-dark"] = Path.Combine(AppContext.BaseDirectory, "Assets", "Email", "logo_on_dark.png")
        };

        public static string EmailSubject(string? lang) => T("emailSubject", lang);

        public static string Email(string firstName, string link, string? lang)
        {
            var l = Lang(lang);
            var greeting = string.Format(T("emailGreeting", l), WebUtility.HtmlEncode(firstName));
            return $$"""
                <!DOCTYPE html>
                <html lang="{{l}}" dir="{{Dir(l)}}">
                <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <meta name="color-scheme" content="light dark">
                <meta name="supported-color-schemes" content="light dark">
                <style>
                :root { color-scheme: light dark; supported-color-schemes: light dark; }
                @media (prefers-color-scheme: dark) {
                  .page { background: #12021F !important; }
                  .card { background: #210635 !important; }
                  .title { color: #F5D5E0 !important; }
                  .text { color: #BFA0C6 !important; }
                  .note { color: #8E7699 !important; }
                  .button { background: #A6A5E6 !important; color: #210635 !important; }
                  .logo-light { display: none !important; }
                  .logo-dark { display: block !important; max-height: none !important; }
                }
                [data-ogsc] .page { background: #12021F !important; }
                [data-ogsc] .card { background: #210635 !important; }
                [data-ogsc] .logo-light { display: none !important; }
                [data-ogsc] .logo-dark { display: block !important; max-height: none !important; }
                </style>
                </head>
                <body style="margin:0;padding:0;">
                <div class="page" dir="{{Dir(l)}}" style="background:#F4ECF5;padding:32px 16px;font-family:Arial,sans-serif;">
                  <div class="card" style="max-width:420px;margin:0 auto;background:#FFFFFF;border-radius:20px;padding:32px 28px;text-align:center;">
                    <img class="logo-light" src="cid:logo-on-light" width="140" alt="Zenda" style="display:block;margin:0 auto;width:140px;height:auto;border:0;">
                    <img class="logo-dark" src="cid:logo-on-dark" width="140" alt="Zenda" style="display:none;margin:0 auto;width:140px;height:auto;border:0;max-height:0;overflow:hidden;">
                    <p class="title" style="margin:24px 0 8px;font-size:16px;font-weight:700;color:#2A0A3D;">{{greeting}}</p>
                    <p class="text" style="margin:0 0 24px;font-size:14px;line-height:1.5;color:#7A6486;">{{T("emailText", l)}}</p>
                    <a class="button" href="{{link}}" style="display:inline-block;padding:14px 28px;background:#7B337E;color:#FDF6FA;text-decoration:none;border-radius:14px;font-size:14px;font-weight:700;">{{T("emailButton", l)}}</a>
                    <p class="note" style="margin:24px 0 0;font-size:12px;line-height:1.5;color:#9A8AA3;">{{T("emailNote", l)}}</p>
                  </div>
                </div>
                </body>
                </html>
                """;
        }
    }
}