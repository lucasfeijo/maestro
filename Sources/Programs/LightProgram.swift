import Foundation

public protocol LightProgram {
    /// Human readable identifier for the program.
    var name: String { get }

    /// Compute the desired light state set for the given context.
    func computeStateSet(context: StateContext) -> LightStateChangeset
}
