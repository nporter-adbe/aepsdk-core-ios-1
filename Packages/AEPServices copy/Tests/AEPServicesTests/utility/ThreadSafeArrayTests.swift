/*
 Copyright 2020 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import XCTest
@testable import AEPCore

class ThreadSafeArrayTests: XCTestCase {
    private var threadSafeArray: ThreadSafeArray<Int>!
    private var dispatchQueueSerial: DispatchQueue!
    private var dispatchQueueConcurrent: DispatchQueue!
    
    override func setUp() {
        threadSafeArray = ThreadSafeArray<Int>()
        dispatchQueueSerial = DispatchQueue(label: "ThreadSafeArrayTests.serial")
        dispatchQueueConcurrent = DispatchQueue(label: "ThreadSafeArrayTests.concurrent", attributes: .concurrent)
    }
    
    // Tests 250 concurrent operations execute as expected, if the threadSafeArray is replaced with a non threadsafe, this test will crash
    func testManyConcurrentOperations() {
        let count = 250
        DispatchQueue.concurrentPerform(iterations: count) { i in
            threadSafeArray.append(i)
        }
        
        XCTAssertEqual(threadSafeArray.count, count)
    }
    
    /// Tests many queues that concurrently write and read to the array
    func testSyncMultipleTimesWithArray() {
        let count = 1000
        let expectation = self.expectation(description: "Test sync")
        let dispatchQueue1 = DispatchQueue(label: "ThreadSafeArrayTests.queue1", attributes: .concurrent)
        let dispatchQueue2 = DispatchQueue(label: "ThreadSafeArrayTests.queue2", attributes: .concurrent)
        expectation.expectedFulfillmentCount = count
        
        // test
        for i in 1...count {
            let rand = Int.random(in: 1..<100)
            if rand % 2 == 0 {
                dispatchQueue1.async {
                    self.dispatchSyncWithArray(i: i)
                    expectation.fulfill()
                }
            } else {
                dispatchQueue2.async {
                    self.dispatchSyncWithArray(i: i)
                    expectation.fulfill()
                }
            }
        }
        
        // verify
        wait(for: [expectation], timeout: 2.0)
    }
    
    
    /// Tests that we can concurrently read and write to the array with concurrent queues
    func testConcurrentReadingAndWriting() {
        // setup
        let count = 1000
        let readingQueue = DispatchQueue(label: "ThreadSafeArrayTests.readingQueue", attributes: .concurrent)
        let writingQueue = DispatchQueue(label: "ThreadSafeArrayTests.writingQueue", attributes: .concurrent)
        let writeExpectation = expectation(description: "Write expectation")
        writeExpectation.expectedFulfillmentCount = count
        let readExpectation = expectation(description: "Read expectation")
        readExpectation.expectedFulfillmentCount = count
        
        // test
        let index = 0
        for i in 0 ..< count {
            writingQueue.async {
                if self.threadSafeArray.isEmpty {
                    self.threadSafeArray.append(i)
                } else {
                    self.threadSafeArray[index] = i
                }
                writeExpectation.fulfill()
            }
            
            readingQueue.async {
                if !self.threadSafeArray.isEmpty {
                    let _ = self.threadSafeArray[index]
                }
                readExpectation.fulfill()
            }
        }
        
        // verify
        wait(for: [writeExpectation, readExpectation], timeout: 5.0)
    }
    
    /// Tests that we can concurrently read and write to the array with concurrent and serial queues
    func testSyncMultipleTimesWithConcurrent() {
        // setup
        let count = 1000
        let expectation = XCTestExpectation(description: "Expectation is full-filled 1000 times")
        expectation.expectedFulfillmentCount = count
        let dispatchQueue1 = DispatchQueue(label: "ThreadSafeArrayTests.queue1", attributes: .concurrent)
        let dispatchQueue2 = DispatchQueue(label: "ThreadSafeArrayTests.queue2", attributes: .concurrent)
        
        // test
        for i in 1...count {
            let rand = Int.random(in: 1..<100)
            if rand % 2 == 0 {
                dispatchQueue1.async {
                    self.dispatchSyncConcurrentOp(i: i)
                    expectation.fulfill()
                }
            } else {
                dispatchQueue2.async {
                    self.dispatchSyncConcurrentOp(i: i)
                    expectation.fulfill()
                }
            }
        }
        
        // verify
        wait(for: [expectation], timeout: 5.0)
    }
    
    private func dispatchSyncWithArray(i: Int) {
        dispatchQueueSerial.sync {
            if threadSafeArray.isEmpty {
                self.threadSafeArray.append(i)
            } else {
                self.threadSafeArray[0] = i
            }
        }
    }
    
    private func dispatchSyncConcurrentOp(i: Int) {
        dispatchQueueSerial.sync {
            dispatchQueueConcurrent.async {
                if self.threadSafeArray.isEmpty {
                    self.threadSafeArray.append(i)
                } else {
                    self.threadSafeArray[0] = i
                }
            }
            
            dispatchQueueConcurrent.async(flags: .barrier) {
                if self.threadSafeArray.isEmpty {
                    self.threadSafeArray.append(i)
                } else {
                    self.threadSafeArray[0] = i
                }
            }
        }
    }
    
}
