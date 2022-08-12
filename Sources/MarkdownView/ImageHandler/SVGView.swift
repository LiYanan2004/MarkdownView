import SwiftUI
import SVGKit

#if os(iOS) || os(tvOS)
struct SVGView: UIViewRepresentable {
    var svgkImage: SVGKImage
    
    func makeUIView(context: Context) -> SVGKFastImageView {
        return SVGKFastImageView(svgkImage: svgkImage)
    }
    
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) { }
}
#elseif os(macOS)
struct SVGView: NSViewRepresentable {
    var svgkImage: SVGKImage
    
    func makeNSView(context: Context) -> SVGKFastImageView {
        return SVGKFastImageView(svgkImage: svgkImage)
    }
    
    func updateNSView(_ nsView: SVGKFastImageView, context: Context) { }
}
#endif
