import Foundation

// MARK: - Utils

public class Utils {}

// MARK: - Sake

public final class Sake<T: RawRepresentable & CustomStringConvertible> where T.RawValue == String {

    fileprivate let utils: Utils = Utils()
    fileprivate let tasks: Tasks<T> = Tasks<T>()
    fileprivate let tasksInitializer: (Tasks<T>) throws -> Void
    fileprivate let printer: (String) -> Void

    public init(tasksInitializer: @escaping (Tasks<T>) throws -> Void) {
        self.tasksInitializer = tasksInitializer
        self.printer = { print($0) }
    }

    init(printer: @escaping (String) -> Void,
         tasksInitializer: @escaping (Tasks<T>) throws -> Void) {
        self.tasksInitializer = tasksInitializer
        self.printer = printer
    }

    init(printer: @escaping (String) -> Void,
         tasksInitializer: @escaping (Tasks<T>) -> Void) {
        self.tasksInitializer = tasksInitializer
        self.printer = printer
    }

}

// MARK: - Sake (Runner)

public extension Sake {

    public func run() {
        var arguments = CommandLine.arguments
        arguments.remove(at: 0)
        run(arguments: arguments)
    }

    func run(arguments: [String]) {
        do {
            try tasksInitializer(tasks)
        } catch {
            printer("> Error initializing tasks: \(error)")
            return
        }
        guard let argument = arguments.first else {
            printer("> Error: Missing argument")
            exit(1)
        }
        if argument == "tasks" {
            printTasks()
        } else if argument == "task" {
            if arguments.count != 2 {
                printer("> Error: Missing task name")
                exit(1)
            }
            do {
                try runTaskAndDependencies(task: arguments[1])
            } catch {
                printer("> Error: \(error)")
                exit(1)
            }
        } else {
            printer("> Error: Invalid argument")
            exit(1)
        }
    }

    // MARK: - Fileprivate

    fileprivate func printTasks() {
        let tasks = self.tasks.tasks
        let longestName = tasks.keys.reduce(0, { return ($1.count > $0) ? $1.count:$0})
        let margin = 5
        printer(self.tasks.tasks
            .map({ task in
                let spaces = (longestName + margin) - task.key.count
                let space = String.init(repeating: " ", count: spaces)
                return "\(task.key):\(space)\(task.value.type.description)"
            })
            .joined(separator: "\n"))
    }
    
    fileprivate func printWarningTaskNotFound(_ task: String) {
        var alertMessage = "> [!] Could not find task '\(task)'"
        if let suggestedTaskName = findSuggestionTaskName(for: task) {
            alertMessage += ". Maybe did you mean '\(suggestedTaskName)'?"
        }
        printer(alertMessage)
    }
    
    /// Find a possible alternative task name. How it work:
    /// 1) Create an array with tuples '(task, distance)', calculating the distance between input task name and the available tasks.
    /// 2) Filter tasks without occurrences (ex: "ci", distance = 2, doesn't have occurrences).
    /// 3) Obtain the task with minimum distance.
    ///
    /// - Parameter task: the task name written by the user
    /// - Returns: alternative task name if exist
    fileprivate func findSuggestionTaskName(for task: String) -> String? {
        let taskWithDistance = self.tasks.tasks.keys
            .map { (taskName: $0, distance: $0.levenshteinDistance(task)) }
            .filter { $0.taskName.count != $0.distance }
            .min { $0.distance < $1.distance }
        return taskWithDistance?.taskName
    }

    fileprivate func runTaskAndDependencies(task taskName: String) throws {
        guard let task = tasks.tasks.first(where: {$0.key == taskName}).map({$0.value}) else {
            printWarningTaskNotFound(taskName)
            return
        }
        tasks.beforeAll.forEach({ $0(utils) })
        defer { tasks.afterAll.forEach({ $0(utils) }) }
        try task.dependencies.forEach { try runTask(task: $0) }
        try runTask(task: taskName)
    }

    fileprivate func runTask(task taskName: String) throws {
        guard let task = tasks.tasks.first(where: {$0.key == taskName}) else {
            printWarningTaskNotFound(taskName)
            return
        }
        printer("> Running \"\(task.key)\"")
        tasks.beforeEach.forEach({$0(utils)})
        try task.value.action(self.utils)
        tasks.afterEach.forEach({$0(utils)})
    }

}

