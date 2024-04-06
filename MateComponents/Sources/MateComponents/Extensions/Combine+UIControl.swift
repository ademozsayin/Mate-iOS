//
//  Combine+UIControl.swift
//  Components
//
//  Created by Adem Özsayın on 29.02.2024.
//

import UIKit
import Combine

/**
 Extension providing Combine publishers for UIControl and UIBarButtonItem events.
 */
extension UIControl {
    
    /**
     Subscription for UIControl events.
     */
    public class InteractionSubscription<S: Subscriber>: Subscription where S.Input == Void {
        private let subscriber: S?
        private let control: UIControl
        private let event: UIControl.Event

        /**
         Initializes the subscription with the provided parameters.
         
         - Parameters:
            - subscriber: The subscriber to receive events.
            - control: The control to observe for events.
            - event: The event to observe.
         */
        public init(
            subscriber: S,
            control: UIControl,
            event: UIControl.Event
        ) {
            self.subscriber = subscriber
            self.control = control
            self.event = event

            self.control.addTarget(self, action: #selector(handleEvent), for: event)
        }

        @objc func handleEvent(_ sender: UIControl) {
            _ = self.subscriber?.receive(())
        }

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {}
    }

    /**
     Publisher for UIControl events.
     */
    public struct InteractionPublisher: Publisher {
        public typealias Output = Void
        public typealias Failure = Never

        private let control: UIControl
        private let event: UIControl.Event

        /**
         Initializes the publisher with the provided parameters.
         
         - Parameters:
            - control: The control to observe for events.
            - event: The event to observe.
         */
        public init(control: UIControl, event: UIControl.Event) {
            self.control = control
            self.event = event
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Void == S.Input {
            let subscription = InteractionSubscription(
                subscriber: subscriber,
                control: control,
                event: event
            )

            subscriber.receive(subscription: subscription)
        }
    }

    /**
     Creates a publisher for the specified UIControl event.
     
     - Parameter event: The UIControl event to observe.
     - Returns: A publisher for the specified event.
     */
    public func publisher(for event: UIControl.Event) -> UIControl.InteractionPublisher {
        return InteractionPublisher(control: self, event: event)
    }
}


/**
 Extension providing Combine publishers for UIBarButtonItem events.
 */
extension UIBarButtonItem {
    
    /**
     Subscription for UIBarButtonItem events.
     */
    final public class InteractionSubscription<S: Subscriber>: Subscription where S.Input == Void {
        private let subscriber: S?
        private var barButton: UIBarButtonItem
        private let event: UIControl.Event

        /**
         Initializes the subscription with the provided parameters.
         
         - Parameters:
            - title: The title for the UIBarButtonItem.
            - subscriber: The subscriber to receive events.
            - event: The event to observe.
         */
        init(
            title: String,
            subscriber: S,
            event: UIControl.Event
        ) {
            self.subscriber = subscriber
            self.event = event
            barButton = UIBarButtonItem()
            defer {
                barButton = UIBarButtonItem(
                    title: title,
                    style: .done,
                    target: self,
                    action: #selector(handleEvent)
                )
            }
        }

        @objc func handleEvent(_ sender: UIControl) {
            _ = self.subscriber?.receive(())
        }

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {}
    }

    /**
     Publisher for UIBarButtonItem events.
     */
    public struct InteractionPublisher: Publisher {
        public typealias Output = Void
        public typealias Failure = Never

        private let event: UIControl.Event
        private let title: String

        /**
         Initializes the publisher with the provided parameters.
         
         - Parameters:
            - event: The event to observe.
            - title: The title for the UIBarButtonItem.
         */
        public init(event: UIControl.Event, title: String) {
            self.event = event
            self.title = title
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Void == S.Input {
            let subscription = InteractionSubscription(
                title: title,
                subscriber: subscriber,
                event: event
            )
            subscriber.receive(subscription: subscription)
        }
    }

    /**
     Creates a publisher for the specified UIBarButtonItem event.
     
     - Parameter event: The UIControl event to observe.
     - Returns: A publisher for the specified event.
     */
    public func publisher(for event: UIControl.Event) -> UIBarButtonItem.InteractionPublisher {
        InteractionPublisher(event: event, title: self.title ?? String())
    }
}
