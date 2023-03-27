import Cocoa

class BundleInfo {
    private static func bundleInfo(_ key: String) -> String {
        return Bundle.main.infoDictionary?[key] as? String ?? ""
    }

    static func iconName() -> String {
        return bundleInfo("CFBundleIconName")
    }
    
    static func displayName() -> String {
        return bundleInfo("CFBundleDisplayName")
    }
    
    static func version() -> String {
        return bundleInfo("CFBundleShortVersionString")
    }
    
    static func build() -> String {
        return bundleInfo("CFBundleVersion")
    }
    
    static func copyright() -> String {
        return bundleInfo("NSHumanReadableCopyright")
    }
}
