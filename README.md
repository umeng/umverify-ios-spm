# UMVerify (U-Verify 端智能登录/一键登录) iOS SDK · Swift Package Manager

友盟+ U-Verify 端智能登录组件 UMVerify v4.0.0 的 Swift Package Manager 分发仓库。

UMVerify 内部已**静态合并阿里云号码认证 ATAuthSDK**（一键登录/本机号码校验能力），
集成方**无需**再单独引入 ATAuthSDK。UMVerify 通过运行时 `NSClassFromString` 读取
UMCommon（UMConfigure/MobClick）的设备与 umid 信息，本包已声明对
[`umcommon-ios-spm`](https://github.com/umeng/umcommon-ios-spm) 的依赖以保证其存在。

## 版本对应关系

| SwiftPM tag | UMVerify | 内置 ATAuthSDK | UMCommon |
| --- | --- | --- | --- |
| `4.0.0` | `4.0.0` | 已合并 | `7.7.0` |

## 环境要求

- iOS 12.0 及以上。
- Xcode 14.0 及以上（Package.swift 使用 Swift tools 5.7）。
- 真机 arm64；模拟器 **arm64 + x86_64**（原生支持 Apple Silicon 模拟器，无需 Rosetta）。

## Xcode 集成

1. **File → Add Package Dependencies**，输入仓库地址：

   ```text
   https://github.com/umeng/umverify-ios-spm.git
   ```

2. 依赖规则选择 **Exact Version**，填写 `4.0.0`。
3. 点击 **Add Package**，将 `UMVerify` product 添加到 App Target。

## Package.swift 集成

```swift
dependencies: [
    .package(url: "https://github.com/umeng/umverify-ios-spm.git", exact: "4.0.0")
],
targets: [
    .target(name: "App", dependencies: [
        .product(name: "UMVerify", package: "umverify-ios-spm")
    ])
]
```

## 使用示例

Objective-C：

```objc
@import UMCommon;   // 或 #import <UMCommon/UMConfigure.h>
@import UMVerify;   // 或 #import <UMVerify/UMCommonHandler.h>

// 1) 初始化统计（可选，但建议：UMVerify 会读取 UMConfigure 的 umid 做风控）
[UMConfigure initWithAppkey:@"<你的统计AppKey>" channel:@"App Store"];

// 2) 初始化 U-Verify（info 为 U-Verify 业务的 AppKey/密钥信息）
[UMCommonHandler setVerifySDKInfo:@"<你的U-Verify SDKInfo>" complete:^(NSDictionary *resultDic) {
    NSLog(@"setVerifySDKInfo: %@", resultDic);
}];

// 3) 预取号（一键登录加速）
[UMCommonHandler accelerateLoginPageWithTimeout:3.0 complete:^(NSDictionary *resultDic) {
    NSLog(@"accelerate: %@", resultDic);
}];

// 4) 拉起授权页，获取一键登录 token
[UMCommonHandler getLoginTokenWithTimeout:3.0
                               controller:self
                                    model:nil
                                 complete:^(NSDictionary *resultDic) {
    NSLog(@"login token result: %@", resultDic);
}];
```

主要接口（`UMCommonHandler`）：

- `+ setVerifySDKInfo:complete:` — 初始化 U-Verify
- `+ checkEnvAvailableWithAuthType:complete:` — 检查当前网络是否支持（`UMPNSAuthTypeLoginToken` 一键登录 / `UMPNSAuthTypeVerifyToken` 本机号校验）
- `+ accelerateLoginPageWithTimeout:complete:` / `+ accelerateVerifyWithTimeout:complete:` — 预取号加速
- `+ getLoginTokenWithTimeout:controller:model:complete:` — 拉起授权页获取登录 token
- `+ getVerifyTokenWithTimeout:complete:` — 本机号码校验 token
- `+ getVersion` / `+ getVerifyId`
- `UMCustomModel` — 自定义授权页 UI

SDK 详细使用请参考 [友盟 U-Verify 官方文档](https://devs.umeng.com/docs/143070/detail/2986091)。

## ⚠️ 集成必读

### 1. 建议添加 `-ObjC` 链接标志

UMVerify（含合并的 ATAuthSDK）为**静态库**，含 Objective-C 分类。若出现分类方法未加载 /
`unrecognized selector`，请在 App Target 的 **Other Linker Flags** 添加 `-ObjC`
（CocoaPods 会自动加，SwiftPM 不会）。

### 2. 系统依赖已在 shim 中声明

`UMVerifyShim` 已通过 `linkerSettings` 声明所需系统库：Security、CoreTelephony、
SystemConfiguration、CoreGraphics、QuartzCore、WebKit，以及 sqlite3 / z / c++。
集成方一般无需再手动添加。

### 3. ATAuthSDK.bundle 资源加载说明

`ATAuthSDK.bundle`（一键登录授权页图标等 UI 资源）已随包通过 SwiftPM 资源机制携带。
但 ATAuthSDK 运行时从 **App 主 Bundle 根目录** 查找该 bundle，而 SwiftPM 会把资源放进
带命名空间的资源包（`App.app/umverify-ios-spm_UMVerifyShim.bundle/ATAuthSDK.bundle`），
两者路径不一致。**若授权页图标缺失**，请手动把 `ATAuthSDK.bundle`
（位于本仓库 `Sources/UMVerifyShim/ATAuthSDK.bundle`）拖入 App Target 的
**Copy Bundle Resources**。

## 仓库结构

```
umverify-ios-spm/
├── Package.swift
├── README.md
├── .gitignore
├── UMVerify.xcframework/            # ios-arm64 + ios-arm64_x86_64-simulator，已合并 ATAuthSDK
└── Sources/UMVerifyShim/
    ├── UMVerifyShim.swift           # shim：承载资源/linker/UMCommon 依赖
    └── ATAuthSDK.bundle/            # 一键登录授权页 UI 资源
```

## 许可

UMVerify 为友盟版权所有；内含的 ATAuthSDK 为阿里云号码认证服务 SDK，
使用须遵循友盟及阿里云相关协议。
