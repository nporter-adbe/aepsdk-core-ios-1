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

import Foundation

@testable import AEPCore

class MockExtensionTwo: Extension {
    var name = "mockExtensionTwo"
    var version = "0.0.1"
    
    static var calledInit = false
    static var calledOnRegistered = false
    static var calledOnUnregistered = false
    
    required init() {
        MockExtensionTwo.calledInit = true
    }
    
    func onRegistered() {
        MockExtensionTwo.calledOnRegistered = true
    }
    
    func onUnregistered() {
        MockExtensionTwo.calledOnUnregistered = true
    }
    
    // MARK: Test helpers
    
    static func reset() {
        MockExtensionTwo.calledInit = false
        MockExtensionTwo.calledOnRegistered = false
        MockExtensionTwo.calledOnUnregistered = false
    }
    
}
