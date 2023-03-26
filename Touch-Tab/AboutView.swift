import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(nsImage: NSImage(named: AboutView.iconName()) ?? NSImage())
                .resizable()
                .frame(width: 64, height: 64)
            Text(AboutView.displayName())
                .font(.system(size: 16, weight: .bold))
            Text("Version \(AboutView.version()) (\(AboutView.build()))")
                .font(.system(size: 12))
            Text("Copyright \(AboutView.copyright())")
                .font(.system(size: 12))
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
    }

    private static func bundleInfo(_ key: String) -> String {
        return Bundle.main.infoDictionary?[key] as? String ?? ""
    }

    private static func iconName() -> String {
        return bundleInfo("CFBundleIconName")
    }
    
    private static func displayName() -> String {
        return bundleInfo("CFBundleDisplayName")
    }
    
    private static func version() -> String {
        return bundleInfo("CFBundleShortVersionString")
    }
    
    private static func build() -> String {
        return bundleInfo("CFBundleVersion")
    }
    
    private static func copyright() -> String {
        return bundleInfo("NSHumanReadableCopyright")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
