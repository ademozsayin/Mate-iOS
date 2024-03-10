// Generated using Sourcery 1.0.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Networking

extension Networking.City {
    /// Returns a "ready to use" type filled with fake values.
    ///
    public static func fake() -> Networking.City {
        .init(
            sunset: .fake(),
            country: .fake(),
            id: .fake(),
            coord: .fake(),
            population: .fake(),
            timezone: .fake(),
            sunrise: .fake(),
            name: .fake()
        )
    }
}
extension Networking.CityResult {
    /// Returns a "ready to use" type filled with fake values.
    ///
    public static func fake() -> Networking.CityResult {
        .init(
            base: .fake(),
            id: .fake(),
            dt: .fake(),
            main: .fake(),
            coord: .fake(),
            wind: .fake(),
            sys: .fake(),
            weather: .fake(),
            visibility: .fake(),
            clouds: .fake(),
            timezone: .fake(),
            cod: .fake(),
            name: .fake()
        )
    }
}
extension Networking.Clouds {
    /// Returns a "ready to use" type filled with fake values.
    ///
    public static func fake() -> Networking.Clouds {
        .init(
            all: .fake()
        )
    }
}
extension Networking.Coord {
    /// Returns a "ready to use" type filled with fake values.
    ///
    public static func fake() -> Networking.Coord {
        .init(
            lon: .fake(),
            lat: .fake()
        )
    }
}
extension Networking.Forecast {
    /// Returns a "ready to use" type filled with fake values.
    ///
    public static func fake() -> Networking.Forecast {
        .init(
            message: .fake(),
            cod: .fake(),
            cnt: .fake(),
            list: .fake(),
            city: .fake()
        )
    }
}
extension Networking.List {
    /// Returns a "ready to use" type filled with fake values.
    ///
    public static func fake() -> Networking.List {
        .init(
            dt: .fake(),
            dtTxt: .fake(),
            main: .fake(),
            weather: .fake(),
            pop: .fake(),
            visibility: .fake()
        )
    }
}
extension Networking.Main {
    /// Returns a "ready to use" type filled with fake values.
    ///
    public static func fake() -> Networking.Main {
        .init(
            temp: .fake(),
            temp_min: .fake(),
            temp_max: .fake(),
            humidity: .fake()
        )
    }
}
extension Networking.Sys {
    /// Returns a "ready to use" type filled with fake values.
    ///
    public static func fake() -> Networking.Sys {
        .init(
            id: .fake(),
            country: .fake(),
            sunset: .fake(),
            type: .fake(),
            sunrise: .fake()
        )
    }
}
extension Networking.Weather {
    /// Returns a "ready to use" type filled with fake values.
    ///
    public static func fake() -> Networking.Weather {
        .init(
            id: .fake(),
            main: .fake(),
            icon: .fake(),
            description: .fake()
        )
    }
}
extension Networking.WeatherResponse {
    /// Returns a "ready to use" type filled with fake values.
    ///
    public static func fake() -> Networking.WeatherResponse {
        .init(
            coord: .fake(),
            weather: .fake(),
            main: .fake(),
            name: .fake(),
            cod: .fake()
        )
    }
}
extension Networking.WeatherType {
    /// Returns a "ready to use" type filled with fake values.
    ///
    public static func fake() -> Networking.WeatherType {
        .clearSky
    }
}
extension Networking.Wind {
    /// Returns a "ready to use" type filled with fake values.
    ///
    public static func fake() -> Networking.Wind {
        .init(
            speed: .fake(),
            deg: .fake(),
            gust: .fake()
        )
    }
}

