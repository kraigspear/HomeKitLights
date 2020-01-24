//
//  BaseOperation.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/10/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation

/// Base class that provides convience methods on top of `Operation`
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

    /// Override to provide code to execute in the operation
    open override func main() {
        done()
    }

    /// Did any dependency of this BaseOperation have an error
    final var anyDependencyHasErrors: Bool {
        firstDependencyError != nil
    }

    /// First error found in any dependency of this operation
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

    /// The value of this property is true if the operation is currently executing its main task or false if it is not.
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
     The value of this property is true if the operation has finished its main task or false if it is executing that task or has not yet started it.
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
    /// is successful or not. Will not be removed from queue if not called.
    public final func done() {
        isExecuting = false
        isFinished = true
    }
}
