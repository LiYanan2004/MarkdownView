import SwiftUI

class ScrollProxyRef {
    static var shared = ScrollProxyRef()
    var proxy: ScrollViewProxy?
}
