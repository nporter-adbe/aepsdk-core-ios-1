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

/// Core extension for the Adobe Experience Platform SDK
public final class AEPCore {
    
    /// Current version of the Core extension
    let version = "0.0.1"
    
    /// Pending extensions to be registered for legacy support
    static var pendingExtensions = ThreadSafeArray<Extension.Type>(identifier: "com.adobe.pendingextensions.queue")
    
    /// Registers the extensions with Core and begins event processing
    /// - Parameter extensions: The extensions to be registered
    public static func registerExtensions(_ extensions: [Extension.Type]) {
//        extensions.insert(AEPConfiguration.self, at: 0) TODO: Uncomment after Configuration is merged
        
        let registeredCounter = AtomicCounter()
        for exten in extensions {
            EventHub.shared.registerExtension(exten) { (error) in
                // Only start `EventHub` processing after all extensions have been registered
                if registeredCounter.incrementAndGet() == extensions.count {
                    EventHub.shared.start()
                }
            }
        }
    }
    
    /// Dispatches an `Event` through the `EventHub`
    /// - Parameter event: The `Event` to be dispatched
    public static func dispatch(event: Event) {
        EventHub.shared.dispatch(event: event)
    }
    
    /// Dispatches an `Event` through the `EventHub` and invokes a closure with the response `Event`.
    /// - Parameters:
    ///   - event: The trigger `Event` to be dispatched through the `EventHub`
    ///   - responseCallback: Callback to be invoked with `event`'s response `Event`
    public static func dispatch(event: Event, responseCallback: (Event) -> ()) {
        // TODO: Uncomment when configuration is merged
//        EventHub.shared.registerResponseListener(parentExtension: AEPConfiguration.self, triggerEvent: event) { (event) in
//            responseCallback(event)
//        }
        
        EventHub.shared.dispatch(event: event)
    }
    
    /// Start event processing
    //@available(*, deprecated, message: "Use `registerExtensions(extensions:)` for both registering extensions and starting the SDK")
    public static func start(completion: @escaping (()-> Void)) {
        // Start the event hub processing
        registerExtensions(AEPCore.pendingExtensions.shallowCopy)
        // Use a background thread for the completion handler since calling thread is most likely going to be main thread.
        DispatchQueue.global(qos: .background).async {
            completion()
        }
    }
        
}
