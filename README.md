# وِصال | دعوات الزفاف

تطبيق Flutter Web بالعربية يتيح معاينة تصاميم دعوات الزفاف، تعديل بيانات العروسين والأهل والموعد والمكان، وحفظ المسودات في المتصفح. تعرض صفحة الضيف العدّ التنازلي بتوقيت الأردن وتفتح موقع الحفل على الخريطة.

## التشغيل

```sh
flutter pub get
flutter run -d chrome
```

## النشر

```sh
flutter build web --no-web-resources-cdn
```

ارفع محتويات `build/web` إلى استضافة ويب ثابتة بعنوان HTTPS. إذا كان التطبيق تحت مسار فرعي، استخدم `--base-href /اسم-المسار/` عند البناء.

المسودات محفوظة على المتصفح الذي أنشأها. رابط المشاركة يحمل نسخة من بيانات الدعوة في جزء الرابط بعد علامة `#`، ويعمل لدى الضيوف عند فتحه على النسخة المستضافة. بعد تعديل الدعوة، شارك الرابط الجديد.

القوالب تستخدم نموذج بيانات واحدًا في `lib/invitation.dart`. لإضافة تصميم، أضف تعريفه إلى `InvitationStyle` وخلفيته إلى `assets/images/`. بنية صفحة الضيف المشتركة في `lib/invitation_view.dart`.

[مرجع لنماذج بطاقات زفاف أردنية مطبوعة](https://eprints.hud.ac.uk/id/eprint/28708/1/Final%20thesis%20-%20SAWALMEH.pdf)

[مرجع توقيت الأردن في قاعدة بيانات المناطق الزمنية](https://www.iana.org/time-zones/releases/2022e)

## Firebase

تطبيق الويب مربوط بمشروع `wedding-projects-15a73` من خلال حزمتَي `firebase_core` و`firebase_analytics`. إعدادات الاتصال موجودة في `lib/firebase_options.dart`، ويبدأ التهيئة في `lib/main.dart` بعد عرض الواجهة.

تُستخدم عناوين صفحات عامة في Analytics لحماية بيانات الدعوة الموجودة في الرابط والعنوان. يمكن متابعة الزيارات من Analytics في Firebase Console.

حفظ المسودات الحالي محلي في المتصفح. مزامنة الدعوات بين الأجهزة تتطلب إضافة Firestore وتحديد تسجيل الدخول وقواعد الوصول.

[إعداد Firebase مع Flutter](https://firebase.google.com/docs/flutter/setup)
# Weeding-Project
# Weeding-Project
# Weeding-Project
