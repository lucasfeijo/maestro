import Foundation

public protocol LightProgram {
    func computeStateSet(context: StateContext) -> LightStateSet
}
