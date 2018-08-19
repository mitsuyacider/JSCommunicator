import Foundation

struct Settings {

    // MARK: - Properties

    static var serverAddress: String {
        return shared.defaults.string(forKey: "server_address")!
    }

    // MARK: - Properties (Private)

    static private let shared = Settings()

    private var defaults: UserDefaults {
        return UserDefaults.standard
    }

    // MARK: - Initialization

    private init() {
        // Register default values using property list from Settings.bundle.
        if
            let url = Bundle.main.url(forResource: "Root", withExtension: "plist", subdirectory: "Settings.bundle"),
            let settings = NSDictionary(contentsOf: url),
            let specifiers = settings["PreferenceSpecifiers"] as? [[String: AnyObject]]
        {
            var defaults: [String: AnyObject] = [:]

            for specifier in specifiers {
                if let key = specifier["Key"] as? String {
                    defaults[key] = specifier["DefaultValue"]
                }
            }

            UserDefaults.standard.register(defaults: defaults)
        }
    }

}
