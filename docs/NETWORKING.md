# Networking
> This module encapsulates the implementation of the network requests, including parsing of results and relevant model objects.  

## High level class diagram
![Networking high level class diagram](images/networking.png)

## [`Remote`](../Networking/Networking/Remote/Remote.swift)
A `Remote` performs network requests. This is the core of this module.  


## [`Network`](../Networking/Networking/Network/Network.swift)
A protocol that abstracts the networking stack. 



## Model objects
Model objects declared in `Networking` are immutable, and modelled as value types (structs) that typically implement `Decodable`.
