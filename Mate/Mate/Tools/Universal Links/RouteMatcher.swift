import Foundation

/// This struct enriches a route with the parameters that came along with the URL,
/// making it possible to perform the route action
///
struct MatchedRoute {
    let route: Route
    let subPath: String
    let parameters: [String: String]

    func performAction() -> Bool {
        route.perform(for: subPath, with: parameters)
    }
}

/// RouterMatcher finds URL routes with paths that match the path of a specified URL,
/// and extracts parameters from the URL.
///
class RouteMatcher {
//    private let mobilePathSegment = "/mobile"
    private let mobilePathSegment = "/"
    let routes: [Route]

    /// - parameter routes: A collection of routes to match against.
    init(routes: [Route]) {
        self.routes = routes
    }

    /// Validates, compares and matches the given URL with the routes previously passed.
    /// If the URL doesn't have the mobile path segment (universal link is not mobile) nil is returned.
    ///
    /// - Parameter url: The universal link URL to be analyzed
    ///
    /// - Returns: The MatchedRoute object with the Route and url query parameters
    ///
    func firstRouteMatching(_ url: URL) -> MatchedRoute? {
        guard let components = URLComponents(string: url.absoluteString),
              components.path.hasPrefix(mobilePathSegment) else {
            return nil
        }

        let routeSubPath = components.path.removingPrefix(mobilePathSegment)
            .removingPrefix("/")
            .removingSuffix("/")

        guard let firstRoute = routes.first(where: { $0.canHandle(subPath: routeSubPath) }) else {
            return nil
        }

        guard let queryItems = components.queryItems else {
            return MatchedRoute(route: firstRoute, subPath: routeSubPath, parameters: [:])
        }

        return MatchedRoute(route: firstRoute, subPath: routeSubPath, parameters: parameters(from: queryItems))
    }
}

private extension RouteMatcher {
    func parameters(from queryItems: [URLQueryItem]) -> [String: String] {
        var parameters: [String: String] = [:]
        for queryItem in queryItems {
            guard let value = queryItem.value else {
                continue
            }

            parameters[queryItem.name] = value
        }

        return parameters
    }
}