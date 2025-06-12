import Foundation

public protocol LightStateDiffer {
    func makeDiff(context: StateContext) -> LightStateDiff
}
