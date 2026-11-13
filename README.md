# وِصال | دعوات الزفاف

تطبيق Flutter Web بالعربية يتيح معاينة تصاميم دعوات الزفاف، تعديل بيانات العروسين والأهل والموعد والمكان، وحفظ المسودات في المتصفح. تعرض صفحة الضيف العدّ التنازلي بتوقيت الأردن وتفتح موقع الحفل على الخريطة.

## التشغيل

```sh
flutter pub get
flutter run -d chrome
```

## النشر

```sh
sh tool/build_web.sh
firebase deploy --only firestore:rules,hosting --project wedding-projects-15a73
```

فعّل Cloud Firestore وأنشئ قاعدة البيانات الافتراضية في مشروع Firebase قبل أول نشر. تخدم Firebase Hosting روابط الدعوات القصيرة من المسار `/i/` على النطاق المنشور.

المسودات محفوظة على المتصفح الذي أنشأها. عند المشاركة، تُحفظ نسخة الدعوة في Firestore ويُنشأ رابط قصير يفتح للضيوف مباشرةً. بعد تعديل الدعوة، شارك الرابط الجديد. الروابط السابقة تعمل عند فتح عنوانها الكامل.

القوالب تستخدم نموذج بيانات واحدًا في `lib/invitation.dart`. لإضافة تصميم، أضف تعريفه إلى `InvitationStyle` وخلفيته إلى `assets/images/`. بنية صفحة الضيف المشتركة في `lib/invitation_view.dart`.

[مرجع لنماذج بطاقات زفاف أردنية مطبوعة](https://eprints.hud.ac.uk/id/eprint/28708/1/Final%20thesis%20-%20SAWALMEH.pdf)

[مرجع توقيت الأردن في قاعدة بيانات المناطق الزمنية](https://www.iana.org/time-zones/releases/2022e)

## Firebase

تطبيق الويب مربوط بمشروع `wedding-projects-15a73` من خلال حزمتَي `firebase_core` و`firebase_analytics`. إعدادات الاتصال موجودة في `lib/firebase_options.dart`، ويبدأ التهيئة في `lib/main.dart` بعد عرض الواجهة.

تُستخدم عناوين صفحات عامة في Analytics لحماية بيانات الدعوة الموجودة في الرابط والعنوان. يمكن متابعة الزيارات من Analytics في Firebase Console.

يتطلب المعرض والمحرّر تسجيل الدخول بالبريد الإلكتروني وكلمة المرور. يمكن للضيوف فتح رابط الدعوة مباشرةً. لإتاحة الدخول، أضف حسابًا من **Authentication → Users → Add user** في Firebase Console.

تسمح قواعد Firestore للزائر بقراءة دعوة مشتركة عبر معرّفها. يتطلب إنشاء رابط جديد تسجيل الدخول بالبريد الإلكتروني وكلمة المرور.

[إعداد Firebase مع Flutter](https://firebase.google.com/docs/flutter/setup)
# Weeding-Project
# Weeding-Project
# Weeding-Project
