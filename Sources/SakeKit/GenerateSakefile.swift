import Foundation

/// Generates a base Sakefile.swift
public class GenerateSakefile {
    
    // MARK: - Attributes

    /// Path to the folder where the Sakefile.swift will be generated.
    fileprivate let path: String

    /// File manager.
    fileprivate let fileManager: FileManager = .default
    
    // MARK: - Init
    
    /// Initializes the command that generates a base Sakefile.swift
    ///
    /// - Parameter path: path to the folder where the Sakefile.swift will be generated.
    public init(path: String) {
        self.path = path
    }
    
    // MARK: - Public
    
    /// Generates the base Sakefile.swift.
    ///
    /// - Throws: an error if the generation fails.
    public func execute() throws {
        let sakefilePath = URL.init(fileURLWithPath: path).appendingPathComponent("Sakefile.swift")
        if fileManager.fileExists(atPath: sakefilePath.path) {
            throw "There's a Sakefile already at \(sakefilePath.path)"
        }
        try GenerateSakefile.defaultContent()
            .write(to: sakefilePath, atomically: true, encoding: .utf8)
        print("Sakefile.swift generated")
    }
    
    static func defaultContent() -> String {
        return """
        import SakefileDescription
        import SakefileUtils
        
        enum Task: String, CustomStringConvertible {
            case build
            var description: String {
                switch self {
                    case .build:
                        return "Builds the project"
                }
            }
        }
        
        Sake<Task> {
            try $0.task(.build) { (utils) in
                // Here is where you define your build task
            }
        }
        """
    }
    
}
