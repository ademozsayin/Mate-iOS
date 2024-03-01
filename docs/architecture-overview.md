# Architecture Overview


VIPER Architecture
The project follows the VIPER architecture pattern, which stands for:

View: Responsible for displaying data to the user and capturing user interactions. In WeatherApp-iOS, views are implemented using UIKit components such as UIViewController and UITableView.

Interactor: Contains business logic and performs data operations. It communicates with the data layer and notifies the presenter about the results. In WeatherApp-iOS, interactors fetch weather data from the server and process it.

Presenter: Acts as a mediator between the view and the interactor. It receives data from the interactor and formats it for display in the view. In WeatherApp-iOS, presenters handle data formatting and pass it to the view.

Entity: Represents the data models used in the application. In WeatherApp-iOS, entities represent weather-related data structures such as City and Weather.

Router: Handles navigation between screens/modules. It decouples the view from the navigation logic. In WeatherApp-iOS, routers handle navigation within the application.


## **Design Principles**

Throughout the entire architecture design process, we've priorized several key concepts which guided us all the way:


1.  **Do NOT Reinvent the Wheel**

        Our main goal is to exploit as much as possible all of the things the platform already offers through its SDK,
        for obvious reasons.

        The -non extensive- list of tools we've built upon include: [CoreData, NotificationCenter, KVO]


2.  **Separation of concerns**

        We've emphasized a clean separation of concerns at the top level, by splitting our app into four targets:

        1.  Storage.framework:
            Wraps up all of the actual CoreData interactions, and exposes a framework-agnostic Public API.

        2.  Networking.framework:
            In charge of providing a Swift API around the Weather REST Endpoints.


        3.  WeatherApp:
            Our main target.


3.  **Immutability**

4.  **Testability**

5.  **Keeping it Simple**



## **Storage.framework**

CoreData interactions are contained within the Storage framework. A set of protocols has been defined, which would, in theory, allow us to
replace CoreData with any other database. Key notes:



## **Networking.framework**

Our Networking framework offers a Swift API around the WeatherApi's RESTful endpoints. In this section we'll do a walkthru around several
key points.

More on [Networking](NETWORKING.md)

### Model Entities

ReadOnly Model Entities live at the Networking Layer level. This effectively translates into: **none** of the Models at this level is expected to have
even a single mutable property.

Each one of the concrete structures conforms to Swift's  `Decodable`  protocol, which is heavily used for JSON Parsing purposes.



### Parsing Model Entities!

In order to maximize separation of concerns, parsing backend responses into Model Entities is expected to be performed (only) by means of
a  concrete `Mapper` implementation:

    ```
    protocol Mapper {
        associatedtype Output
        func map(response: Data) throws -> Output
    }
    ```

Since our Model entities conform to `Decodable`, this results in small-footprint-mappers, along with clean and compact Unit Tests.



### Network Access

The networking layer is **entirely decoupled** from third party frameworks. We rely upon component injection to actually perform network requests:



### Building Requests


## **LocationService.framework**

The [LocationService framework](LocationService.md) is the keystone of our architecture. Encapsulates all of the Business Logic of our app, and interacts with both the Networking and
Storage layers.

More on [LocationService](LocationService.md)


### Main Concepts


## **Components.framework**

Reusable view components

More on [Components](Components.md)


### Model Entities

It's important to note that in the proposed architecture Model Entities must be defined in two spots:

A.  **Storage.framework**

        New entities are defined in the CoreData Model, and its code is generated thru the Model Editor.

B.  **Networking.framework**

        Entities are typically implemented as `structs` with readonly properties, and Decodable conformance.

## WeatherApp

The outer layer is where the UI and the business logic associated to it belongs to.

It is important to note that at the moment there is not a global unified architecture of this layer, but more of a micro-architecture oriented approach and the general idea that business logic should be detached from view controllers.

That being said, there are some high-level abstractions that are starting to pop up.

### Global Dependencies and the Service Locator pattern
