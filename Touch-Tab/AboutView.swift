import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(nsImage: NSImage(named: BundleInfo.iconName()) ?? NSImage())
                .resizable()
                .frame(width: 64, height: 64)
            Text(BundleInfo.displayName())
                .font(.system(size: 16, weight: .bold))
            Text("Version \(BundleInfo.version()) (\(BundleInfo.build()))")
                .font(.system(size: 12))
            Text("Copyright \(BundleInfo.copyright())")
                .font(.system(size: 12))
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
