//
//  BaseOperation.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/10/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation

open class BaseOperation: Operation {
    /// Indicates if there was an error executing the operation. Nil if the operation was a
    /// Success or an error otherwise.
    public var error: Error?

    /**
     Override of NSOperation start.
     Not intended to be overridden in BaseOperation child classes
     */
    public final override func start() {
        if isCancelled {
            isFinished = true
        } else {
            isExecuting = true
            main()
        }
    }

    open override func main() {
        done()
    }

    final var anyDependencyHasErrors: Bool {
        firstDependencyError != nil
    }

    var firstDependencyError: Error? {
        for dependency in dependencies {
            if let baseOperation = dependency as? BaseOperation {
                if let error = baseOperation.error {
                    return error
                }
            }
        }
        return nil
    }

    /**
     Always true.
     Not intended to be overridden
     */
    public final override var isAsynchronous: Bool {
        true
    }

    private var _executing = false

    private let executingKey = "isExecuting"
    public final override var isExecuting: Bool {
        get {
            _executing
        }
        set {
            willChangeValue(forKey: executingKey)
            _executing = newValue
            didChangeValue(forKey: executingKey)
        }
    }

    private var _finished: Bool = false
    private let finishedKey = "isFinished"

    /**
     True if the operation is finished
     */
    public final override var isFinished: Bool {
        get {
            _finished
        }
        set {
            willChangeValue(forKey: finishedKey)
            _finished = newValue
            didChangeValue(forKey: finishedKey)
        }
    }

    /// Set this operation as being completed. Needs to always be called no matter if the operation
    /// is successful or not
    public final func done() {
        isExecuting = false
        isFinished = true
    }
}
