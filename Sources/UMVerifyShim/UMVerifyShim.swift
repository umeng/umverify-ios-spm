// Shim target for U-Verify (UMVerify.framework, 端智能登录/一键登录).
//
// Binary targets in SwiftPM cannot declare dependencies, resources or linker
// settings, so this target carries:
//   * ATAuthSDK.bundle (the 一键登录 auth-page UI resources),
//   * the system frameworks/libraries that UMVerify + the statically merged
//     ATAuthSDK require at app link time,
//   * the dependency on UMCommon (UMVerify reads device/umid info from
//     UMConfigure/MobClick at runtime via NSClassFromString).
// No public API is exposed; `import UMVerify` resolves to the binary
// framework's module.
import Foundation

/// The SwiftPM resource bundle that contains `ATAuthSDK.bundle`.
public enum UMVerifyResources {
    public static let bundle: Bundle = Bundle.module
}
