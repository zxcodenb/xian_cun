# 📱 平台权限配置指南

## 概述

本指南说明如何配置Android和iOS平台的相机和存储权限，以支持AI拍照识别功能。

## 🔐 Android配置

### 1. AndroidManifest.xml

在 `android/app/src/main/AndroidManifest.xml` 中添加权限：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.xian_cun">

    <!-- 相机权限 -->
    <uses-permission android:name="android.permission.CAMERA" />

    <!-- 存储权限（Android 10及以下） -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="28" />

    <!-- 网络权限（用于API调用） -->
    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:label="Apple Pantry"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <!-- 指定启动页面 -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- 不保留活动状态 -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### 2. Android 6.0+ 运行时权限处理

Flutter的 `image_picker` 插件会自动处理运行时权限，但建议在代码中手动请求权限：

```dart
import 'package:permission_handler/permission_handler.dart';

class CameraCaptureScreen extends StatefulWidget {
  // ...
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  // ...

  /// 拍照前检查权限
  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final storageStatus = await Permission.storage.status;

    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
    if (!storageStatus.isGranted && Platform.isAndroid) {
      await Permission.storage.request();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  // ...
}
```

### 3. 添加权限处理依赖

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  permission_handler: ^11.0.1
```

然后运行：
```bash
flutter pub get
```

## 🍎 iOS配置

### 1. Info.plist配置

在 `ios/Runner/Info.plist` 中添加相机和相册访问权限：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 其他现有配置... -->

    <!-- 相机权限 -->
    <key>NSCameraUsageDescription</key>
    <string>我们需要访问您的相机来拍照识别商品信息</string>

    <!-- 相册权限 -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>我们需要访问您的相册来选择商品图片</string>

    <!-- 保存到相册权限（可选） -->
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>我们需要保存图片到您的相册</string>
    <!-- 其他配置... -->
</dict>
</plist>
```

### 2. iOS权限配置检查清单

确保以下配置正确：

#### Camera权限
- `NSCameraUsageDescription` - 描述使用相机的原因
- 必须非空，且清晰说明用途

#### Photo Library权限
- `NSPhotoLibraryUsageDescription` - 读取相册的权限
- `NSPhotoLibraryAddUsageDescription` - 保存到相册的权限（iOS 11+）

#### 示例配置
```xml
<key>NSCameraUsageDescription</key>
<string>相机用于拍摄商品照片，AI将自动识别商品信息</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>选择相册中的商品图片进行AI识别</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>保存识别结果或编辑后的图片</string>
```

### 3. iOS权限请求代码

```dart
import 'package:permission_handler/permission_handler.dart';

class CameraCaptureScreen extends StatefulWidget {
  // ...
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  // ...

  Future<void> _requestPermissions() async {
    // iOS 14+ 需要使用 Photos 权限
    if (Platform.isIOS) {
      final photosStatus = await Permission.photos.status;
      if (!photosStatus.isGranted) {
        await Permission.photos.request();
      }
    }

    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  // ...
}
```

## 📋 权限配置检查表

### Android
- [ ] `AndroidManifest.xml` 中添加相机权限
- [ ] `AndroidManifest.xml` 中添加存储权限
- [ ] `AndroidManifest.xml` 中添加网络权限
- [ ] 添加运行时权限处理代码
- [ ] 测试Android 6.0+设备

### iOS
- [ ] `Info.plist` 中添加 `NSCameraUsageDescription`
- [ ] `Info.plist` 中添加 `NSPhotoLibraryUsageDescription`
- [ ] `Info.plist` 中添加 `NSPhotoLibraryAddUsageDescription`
- [ ] 所有描述文案非空且清晰
- [ ] 测试iOS真机设备

## 🧪 测试权限

### 测试Android权限

```bash
# 在Android设备上运行
flutter run
```

1. 打开应用
2. 进入"新增" → "拍照添加"
3. 首次访问会弹出权限请求
4. 选择"允许"
5. 验证相机能正常打开

### 测试iOS权限

```bash
# 在iOS设备上运行
flutter run
```

1. 打开应用
2. 进入"新增" → "拍照添加"
3. 系统会弹出权限请求
4. 选择"允许"
5. 验证相机能正常打开

## ❗ 常见问题

### 问题1：Android模拟器无法打开相机

**解决方案**：
- Android模拟器默认不支持相机
- 使用真机测试，或
- 配置模拟器相机（AVD设置 → Advanced → Camera → Back/Webcam0）

### 问题2：iOS真机测试时崩溃

**可能原因**：
- `Info.plist` 中缺少权限描述
- 权限描述为空字符串
- 权限键名拼写错误

**解决方案**：
- 检查 `Info.plist` 文件
- 确保所有权限键正确配置
- 重新构建应用：`flutter clean && flutter build ios`

### 问题3：权限被拒绝后无法再次请求

**解决方案**：
- 提供"去设置页面"选项
- 使用 `openAppSettings()` 方法

```dart
Future<void> _openSettings() async {
  await openAppSettings();
}
```

### 问题4：部分Android设备权限自动授予

**说明**：
- Android 6.0以下系统会自动授予权限
- 这是正常现象，无需特殊处理

## 🔐 安全建议

1. **最小权限原则**
   - 只请求必要的权限
   - 避免请求不必要的权限

2. **用户友好**
   - 清晰说明权限用途
   - 提供拒绝权限的备选方案

3. **隐私保护**
   - 拍照后不保存到本地（除非需要）
   - 仅上传用于识别的图片
   - 识别完成后可删除临时图片

4. **网络安全**
   - 使用HTTPS传输图片
   - 加密敏感数据

## 📚 相关资源

- [Flutter权限处理文档](https://pub.dev/packages/permission_handler)
- [Android权限最佳实践](https://developer.android.com/training/permissions/requesting)
- [iOS隐私权限](https://developer.apple.com/documentation/uikit)
- [image_picker插件文档](https://pub.dev/packages/image_picker)

---

**版本**: v1.0.0
**最后更新**: 2025-11-24
**开发者**: Claude Code
