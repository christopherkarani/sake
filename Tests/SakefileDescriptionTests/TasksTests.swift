import Foundation
import XCTest

@testable import SakefileDescription

final class TasksTests: XCTestCase {
    
    enum Task: String, CustomStringConvertible {
        case a
        case b
        var description: String {
            return self.rawValue
        }
    }
    
    func test_taskWithClosure_shouldPrintAnError_whenTheTaskIsAlreadyRegistered() {
        var printed: String!
        var exited: Int32!
        Sake<Task>(printer: { printed = $0 },
                   exiter: { exited = $0 },
                   arguments: []) {
                    try $0.task(.a) { (_) in }
                    try $0.task(.a) { (_) in }
        }
        XCTAssertEqual(printed, "> Error initializing tasks: Trying to register task a that is already registered")
        XCTAssertEqual(exited, 1)
    }
    
    func test_taskWithTask_shouldThrow_whenTheTaskIsAlreadyRegistered() {
        var printed: String!
        var exited: Int32!
        let task = SakefileDescription.Task<Task>(type: .a, action: { _ in })
        Sake<Task>(printer: { printed = $0 },
                   exiter: { exited = $0 },
                   arguments: []) {
                    try $0.task(task: task)
                    try $0.task(task: task)
        }
        XCTAssertEqual(printed, "> Error initializing tasks: Trying to register task a that is already registered")
        XCTAssertEqual(exited, 1)
    }
    
}
