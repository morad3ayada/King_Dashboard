# نظام الصلاحيات - King IPTV Dashboard

## نظرة عامة
يستخدم النظام صلاحيات قائمة على الأدوار (Role-Based Access Control) مع دعم Super Admin.

## أنواع المستخدمين

### 1. Super Admin (المدير الرئيسي)
- **الخصائص:**
  - `isSuperAdmin: true`
  - `permissions: []` (لا يحتاج صلاحيات محددة)
  - يتم إنشاؤه تلقائياً بـ ID: `admin_001`
  - Username: `admin`
  - Password: `admin123` (يجب تغييره)

- **الصلاحيات:**
  - ✅ الوصول لجميع الصفحات
  - ✅ إدارة الأدمنز (إضافة، تعديل، حذف)
  - ✅ تعديل الإعدادات العامة
  - ✅ إدارة DNS
  - ✅ إدارة المستخدمين
  - ✅ إدارة أكواد التفعيل
  - ✅ إدارة الرياضة
  - ✅ إدارة الصور

### 2. Sub-Admin (المديرون الفرعيون)
- **الخصائص:**
  - `isSuperAdmin: false`
  - `permissions: ['access_users', 'access_codes', ...]`
  - يتم إنشاؤهم من قبل Super Admin

- **الصلاحيات المتاحة:**
  1. `access_admin` - إدارة الأدمنز والإعدادات
  2. `access_dns` - إدارة DNS
  3. `access_users` - إدارة المستخدمين
  4. `access_codes` - إدارة أكواد التفعيل

- **الصفحات المتاحة دائماً:**
  - Image List (معرض الصور)
  - Sport Settings (إذا كان لديه `access_admin`)

## كيفية عمل النظام

### 1. التحقق من الصلاحيات
```dart
bool _hasPermission(String permission) {
  if (widget.currentUser == null) return true; // Dev mode
  if (widget.currentUser!.isSuperAdmin) return true; // Super Admin
  return widget.currentUser!.permissions.contains(permission); // Sub-Admin
}
```

### 2. عرض القوائم
- يتم فحص الصلاحيات قبل عرض كل عنصر في القائمة
- Super Admin يرى جميع العناصر
- Sub-Admin يرى فقط ما لديه صلاحية له

### 3. إدارة الأدمنز
- فقط من لديه `access_admin` أو Super Admin يمكنه:
  - رؤية قسم "Manage Admins"
  - إضافة أدمنز جدد
  - تعديل أدمنز موجودين
  - حذف أدمنز

## مثال على إنشاء Sub-Admin

```dart
final newAdmin = AdminUser(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: 'أحمد محمد',
  username: 'ahmed',
  email: 'ahmed@example.com',
  password: 'password123', // سيتم تشفيره تلقائياً
  permissions: [
    'access_users',    // يمكنه إدارة المستخدمين
    'access_codes',    // يمكنه إدارة أكواد التفعيل
  ],
  isSuperAdmin: false,
);
```

## الأمان

### تشفير كلمات المرور
- جميع كلمات المرور يتم تشفيرها باستخدام SHA-256
- لا يتم تخزين كلمات المرور بشكل نصي أبداً

### Firebase Security Rules (مقترح)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /admins/{adminId} {
      // فقط المستخدمين المسجلين
      allow read: if request.auth != null;
      // فقط Super Admin يمكنه الكتابة
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.is_super_admin == true;
    }
  }
}
```

## الصفحات والصلاحيات المطلوبة

| الصفحة | الصلاحية المطلوبة | متاح للجميع |
|--------|-------------------|-------------|
| Admin Info | `access_admin` | ❌ |
| DNS Settings | `access_dns` | ❌ |
| MAC Users | `access_users` | ❌ |
| Activation Codes | `access_codes` | ❌ |
| Sport Settings | `access_admin` | ❌ |
| Image List | - | ✅ |

## ملاحظات مهمة

1. **Super Admin دائماً له صلاحيات كاملة** بغض النظر عن قائمة `permissions`
2. **Image List متاح للجميع** لأنه لا يحتوي على بيانات حساسة
3. **يتم مزامنة بيانات Master Admin** بين `settings/config` و `admins/admin_001`
4. **عند تغيير كلمة مرور Master Admin** في صفحة Admin Info، يتم تحديثها في كلا المكانين
