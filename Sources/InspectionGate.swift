import Foundation

struct InspectionGate {
    static let flag = "--inspect-page"
    private static let minimumMajor = 13
    private static let minimumMinor = 3

    static func isEnabled(arguments: [String] = CommandLine.arguments,
                          osMajor: Int,
                          osMinor: Int) -> Bool {
        guard arguments.contains(flag) else { return false }
        if osMajor != minimumMajor {
            return osMajor > minimumMajor
        }
        return osMinor >= minimumMinor
    }
}
