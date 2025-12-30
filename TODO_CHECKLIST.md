# قائمة التحقق من النقاط المطلوبة - تطبيق المطعم

## ✅ النقاط المكتملة (Completed)

### 1. ✅ QR Scanner للطلبات
- **الحالة**: ✅ تم التنفيذ
- **الموقع**: 
  - `lib/app/scan_order_qr_screen/scan_order_qr_screen.dart`
  - `lib/controller/scan_order_qr_controller.dart`
  - `lib/app/Home_screen/home_screen.dart` (زر QR في AppBar)
- **الفحص**: افتح HomeScreen واضغط على أيقونة QR في AppBar

### 2. ✅ Dine-in Sort
- **الحالة**: ✅ تم التنفيذ
- **الموقع**: `lib/utils/fire_store_utils.dart` - دالة `getDineInBooking()`
- **الفحص**: 
  - Upcoming: مرتب حسب التاريخ تصاعدياً ثم createdAt تنازلياً
  - History: مرتب حسب التاريخ تنازلياً ثم createdAt تنازلياً

### 3. ✅ Dine-in Notifications
- **الحالة**: ✅ تم التنفيذ
- **الموقع**: `lib/app/dine_in_order_screen/dine_in_order_screen.dart`
  - Accept: السطر 750 - إرسال `dineInAccepted`
  - Reject: السطر 731 - إرسال `dineInCanceled`
- **الفحص**: عند قبول أو رفض طلب dine-in، يتم إرسال إشعار

### 4. ✅ Guest Number Validation (Min-Max)
- **الحالة**: ✅ تم التنفيذ في تطبيق المستخدم
- **الموقع في User App**: `lib/app/dine_in_screeen/book_table_screen.dart`
- **ملاحظة**: يجب التحقق في تطبيق المطعم إذا كان هناك مكان للتحقق

### 5. ✅ Time Validation (Start before End)
- **الحالة**: ✅ تم التنفيذ
- **الموقع**: `lib/controller/dine_in_settings_controller.dart` - دالة `updateTimeSlot()` السطر 239-247
- **الفحص**: حاول إدخال وقت بداية بعد وقت النهاية، ستظهر رسالة خطأ

### 6. ✅ Default Discount Validation (Not Negative)
- **الحالة**: ✅ تم التنفيذ
- **الموقع**: `lib/controller/dine_in_settings_controller.dart` - دالة `saveSettings()` السطر 318-322
- **الفحص**: حاول إدخال قيمة سالبة للخصم الافتراضي

### 7. ✅ Edit Price - Special Offer Bug Fix
- **الحالة**: ✅ تم التنفيذ
- **الموقع**: 
  - `lib/app/product_screens/add_product_screen.dart` السطر 1122-1147
  - `lib/controller/add_product_controller.dart` السطر 213-235
- **الفحص**: 
  - عند تعديل السعر مع عرض خاص، يجب أن يعمل بشكل صحيح
  - التحقق من أن السعر المخفض أصغر من السعر العادي

### 8. ✅ Product Name Fix (Not Changing to Surprise Bag)
- **الحالة**: ✅ تم التنفيذ
- **الموقع**: `lib/controller/add_product_controller.dart` السطر 245-252
- **الفحص**: عند تعديل سعر منتج عادي، يجب أن يبقى الاسم كما هو

### 9. ✅ Table Count Display
- **الحالة**: ✅ تم التنفيذ
- **الموقع**: `lib/app/dine_in_order_screen/dine_in_order_screen.dart` السطر 627-630
- **الفحص**: يتم عرض عدد الطاولات المتاحة والاحتياطية

---

## ❌ النقاط المعلقة (Pending)

### 1. ❌ Time Schedule Action Button Disabled
- **المشكلة**: عند اختيار المستخدم لجدول زمني، لا يمكن للمطعم القيام بأي إجراء (قبول/رفض)
- **الموقع المتوقع**: `lib/app/dine_in_order_screen/dine_in_order_screen.dart`
- **السطر**: حول 716 - الشرط `isNew == false || (orderModel.status == Constant.orderAccepted || orderModel.status == Constant.orderRejected)`
- **الفحص**: 
  ```dart
  // يجب فحص هذا الشرط - قد يكون يمنع الأزرار من الظهور
  isNew == false || (orderModel.status == Constant.orderAccepted || orderModel.status == Constant.orderRejected)
  ```
- **الحل المقترح**: التحقق من حالة الطلب والتأكد من أن الأزرار تظهر عندما يكون الطلب في حالة `orderPlaced`

### 2. ❌ Timer Count Down in User App
- **المشكلة**: عند الرفض، لا يزال العداد يعمل في تطبيق المستخدم
- **الموقع**: يجب التحقق في تطبيق المستخدم
- **الفحص**: في User App - `lib/app/dine_in_booking/dine_in_booking_details.dart`
- **الحل**: يجب إيقاف/إخفاء العداد عندما يكون status = `orderRejected`

### 3. ❌ Timer Mechanism UX Improvement
- **المشكلة**: آلية الوقت سيئة - يجب تحسينها وإظهار الساعات والدقائق
- **الموقع**: يجب التحقق في تطبيق المستخدم
- **الحل المقترح**: 
  - إظهار الوقت بشكل واضح (ساعات ودقائق)
  - تحسين تجربة المستخدم للعداد

### 4. ❌ Chat - New Chat When Username Changes
- **المشكلة**: عند تغيير اسم المستخدم، يجب إنشاء محادثة جديدة وليس نفس المحادثة
- **الموقع**: `lib/app/chat_screens/chat_screen.dart` السطر 65-69
- **الحالة الحالية**: يستخدم `orderId_customerId` كمعرف للمحادثة
- **الحل المقترح**: 
  ```dart
  // يجب استخدام username في المعرف أو التحقق من تغيير الاسم
  .doc("${controller.orderId.value}_${controller.customerId.value}_${controller.username.value}")
  ```

### 5. ❌ Dine-in - Reject Shows as Accept to User
- **المشكلة**: عند رفض الطلب، يظهر للمستخدم أنه تم القبول
- **الموقع**: `lib/app/dine_in_order_screen/dine_in_order_screen.dart` السطر 728-731
- **الفحص**: التحقق من أن الإشعار المرسل يحتوي على الرسالة الصحيحة
- **الحل**: التأكد من أن `Constant.dineInCanceled` يحتوي على الرسالة الصحيحة

### 6. ❌ Dine-in - Date with Time Display
- **المشكلة**: يجب إضافة التاريخ مع الوقت
- **الموقع**: `lib/app/dine_in_order_screen/dine_in_order_screen.dart`
- **الحل**: عرض التاريخ والوقت معاً في تفاصيل الطلب

### 7. ❌ Dine-in - Discount in Fixed Day Takes Value 0
- **المشكلة**: الخصم في اليوم المحدد يأخذ قيمة 0
- **الموقع**: `lib/controller/dine_in_settings_controller.dart` - دالة `addTimeSlot()`
- **الفحص**: السطر 161 - `discount: defaultDiscount.value`
- **الحل**: يجب التأكد من أن الخصم يتم حفظه بشكل صحيح في timeSlot

### 8. ❌ Cash Payment with Receipt Upload
- **المشكلة**: ميزة معقدة - لم يتم تنفيذها بعد
- **المتطلبات**: 
  - إضافة خيار للمستخدم والمطعم لإدخال سعر الفاتورة
  - رفع صورة اختياري للفاتورة
  - تنبيه في Dashboard عند عدم تطابق السعر
  - إمكانية إضافة المطعم للسعر والدفع من التطبيق
- **الحالة**: ❌ لم يتم التنفيذ - ميزة معقدة تحتاج تخطيط

---

## 📋 ملخص الحالة

| # | النقطة | الحالة | الموقع |
|---|--------|--------|--------|
| 1 | QR Scanner | ✅ | `lib/app/scan_order_qr_screen/` |
| 2 | Dine-in Sort | ✅ | `lib/utils/fire_store_utils.dart:1151` |
| 3 | Dine-in Notifications | ✅ | `lib/app/dine_in_order_screen/dine_in_order_screen.dart:730,750` |
| 4 | Guest Number Validation | ✅ | User App |
| 5 | Time Validation | ✅ | `lib/controller/dine_in_settings_controller.dart:239` |
| 6 | Default Discount | ✅ | `lib/controller/dine_in_settings_controller.dart:318` |
| 7 | Edit Price Bug | ✅ | `lib/app/product_screens/add_product_screen.dart:1122` |
| 8 | Product Name Fix | ✅ | `lib/controller/add_product_controller.dart:245` |
| 9 | Table Count Display | ✅ | `lib/app/dine_in_order_screen/dine_in_order_screen.dart:627` |
| 10 | Time Schedule Action | ❌ | `lib/app/dine_in_order_screen/dine_in_order_screen.dart:716` |
| 11 | Timer Count Down | ❌ | User App |
| 12 | Timer UX | ❌ | User App |
| 13 | Chat Username | ❌ | `lib/app/chat_screens/chat_screen.dart:65` |
| 14 | Reject Shows Accept | ❌ | `lib/app/dine_in_order_screen/dine_in_order_screen.dart:731` |
| 15 | Date with Time | ❌ | `lib/app/dine_in_order_screen/dine_in_order_screen.dart` |
| 16 | Discount Fixed Day | ❌ | `lib/controller/dine_in_settings_controller.dart:161` |
| 17 | Cash Payment | ❌ | Not Implemented |

---

## 🔍 أماكن الفحص المحددة

### للفحص الفوري:

1. **Time Schedule Action Button**:
   ```dart
   // File: lib/app/dine_in_order_screen/dine_in_order_screen.dart
   // Line: 716
   isNew == false || (orderModel.status == Constant.orderAccepted || orderModel.status == Constant.orderRejected)
   ```

2. **Chat Username Issue**:
   ```dart
   // File: lib/app/chat_screens/chat_screen.dart
   // Line: 65-69
   .doc("${controller.orderId.value}_${controller.customerId.value}")
   ```

3. **Discount Fixed Day**:
   ```dart
   // File: lib/controller/dine_in_settings_controller.dart
   // Line: 158-165 - في addTimeSlot()
   discount: defaultDiscount.value,
   ```

4. **Reject Notification**:
   ```dart
   // File: lib/app/dine_in_order_screen/dine_in_order_screen.dart
   // Line: 731
   await SendNotification.sendFcmMessage(Constant.dineInCanceled, ...)
   ```

---

**آخر تحديث**: تم إنشاء الملف بناءً على فحص الكود الحالي




