import Foundation

actor ActorIsolated<Value> {
    var value: Value
    
    init(_ value: Value) {
        self.value = value
    }
}
