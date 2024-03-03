// Generated using Sourcery 1.0.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import CodeGen
import Foundation
import UIKit


extension Networking.City {
    public func copy(
        sunset: NullableCopiableProp<Int> = .copy,
        country: NullableCopiableProp<String> = .copy,
        id: NullableCopiableProp<Int> = .copy,
        coord: NullableCopiableProp<Coord> = .copy,
        population: NullableCopiableProp<Int> = .copy,
        timezone: NullableCopiableProp<Int> = .copy,
        sunrise: NullableCopiableProp<Int> = .copy,
        name: NullableCopiableProp<String> = .copy
    ) -> Networking.City {
        let sunset = sunset ?? self.sunset
        let country = country ?? self.country
        let id = id ?? self.id
        let coord = coord ?? self.coord
        let population = population ?? self.population
        let timezone = timezone ?? self.timezone
        let sunrise = sunrise ?? self.sunrise
        let name = name ?? self.name

        return Networking.City(
            sunset: sunset,
            country: country,
            id: id,
            coord: coord,
            population: population,
            timezone: timezone,
            sunrise: sunrise,
            name: name
        )
    }
}

extension Networking.CityResult {
    public func copy(
        base: NullableCopiableProp<String> = .copy,
        id: NullableCopiableProp<Int> = .copy,
        dt: NullableCopiableProp<Int> = .copy,
        main: NullableCopiableProp<Main> = .copy,
        coord: NullableCopiableProp<Coord> = .copy,
        wind: NullableCopiableProp<Wind> = .copy,
        sys: NullableCopiableProp<Sys> = .copy,
        weather: NullableCopiableProp<[Weather]> = .copy,
        visibility: NullableCopiableProp<Int> = .copy,
        clouds: NullableCopiableProp<Clouds> = .copy,
        timezone: NullableCopiableProp<Int> = .copy,
        cod: NullableCopiableProp<Int> = .copy,
        name: NullableCopiableProp<String> = .copy
    ) -> Networking.CityResult {
        let base = base ?? self.base
        let id = id ?? self.id
        let dt = dt ?? self.dt
        let main = main ?? self.main
        let coord = coord ?? self.coord
        let wind = wind ?? self.wind
        let sys = sys ?? self.sys
        let weather = weather ?? self.weather
        let visibility = visibility ?? self.visibility
        let clouds = clouds ?? self.clouds
        let timezone = timezone ?? self.timezone
        let cod = cod ?? self.cod
        let name = name ?? self.name

        return Networking.CityResult(
            base: base,
            id: id,
            dt: dt,
            main: main,
            coord: coord,
            wind: wind,
            sys: sys,
            weather: weather,
            visibility: visibility,
            clouds: clouds,
            timezone: timezone,
            cod: cod,
            name: name
        )
    }
}

extension Networking.Clouds {
    public func copy(
        all: NullableCopiableProp<Int> = .copy
    ) -> Networking.Clouds {
        let all = all ?? self.all

        return Networking.Clouds(
            all: all
        )
    }
}

extension Networking.Coord {
    public func copy(
        lon: CopiableProp<Double> = .copy,
        lat: CopiableProp<Double> = .copy
    ) -> Networking.Coord {
        let lon = lon ?? self.lon
        let lat = lat ?? self.lat

        return Networking.Coord(
            lon: lon,
            lat: lat
        )
    }
}

extension Networking.Forecast {
    public func copy(
        message: NullableCopiableProp<Int> = .copy,
        cod: NullableCopiableProp<String> = .copy,
        cnt: NullableCopiableProp<Int> = .copy,
        list: NullableCopiableProp<[List]> = .copy,
        city: NullableCopiableProp<City> = .copy
    ) -> Networking.Forecast {
        let message = message ?? self.message
        let cod = cod ?? self.cod
        let cnt = cnt ?? self.cnt
        let list = list ?? self.list
        let city = city ?? self.city

        return Networking.Forecast(
            message: message,
            cod: cod,
            cnt: cnt,
            list: list,
            city: city
        )
    }
}

extension Networking.List {
    public func copy(
        dt: NullableCopiableProp<Int> = .copy,
        dtTxt: NullableCopiableProp<String> = .copy,
        main: NullableCopiableProp<Main> = .copy,
        weather: NullableCopiableProp<[Weather]> = .copy,
        pop: NullableCopiableProp<Double> = .copy,
        visibility: NullableCopiableProp<Int> = .copy
    ) -> Networking.List {
        let dt = dt ?? self.dt
        let dtTxt = dtTxt ?? self.dtTxt
        let main = main ?? self.main
        let weather = weather ?? self.weather
        let pop = pop ?? self.pop
        let visibility = visibility ?? self.visibility

        return Networking.List(
            dt: dt,
            dtTxt: dtTxt,
            main: main,
            weather: weather,
            pop: pop,
            visibility: visibility
        )
    }
}

extension Networking.Main {
    public func copy(
        temp: NullableCopiableProp<Double> = .copy,
        temp_min: NullableCopiableProp<Double> = .copy,
        temp_max: NullableCopiableProp<Double> = .copy,
        humidity: NullableCopiableProp<Double> = .copy
    ) -> Networking.Main {
        let temp = temp ?? self.temp
        let temp_min = temp_min ?? self.temp_min
        let temp_max = temp_max ?? self.temp_max
        let humidity = humidity ?? self.humidity

        return Networking.Main(
            temp: temp,
            temp_min: temp_min,
            temp_max: temp_max,
            humidity: humidity
        )
    }
}

extension Networking.Sys {
    public func copy(
        id: NullableCopiableProp<Int> = .copy,
        country: NullableCopiableProp<String> = .copy,
        sunset: NullableCopiableProp<Int> = .copy,
        type: NullableCopiableProp<Int> = .copy,
        sunrise: NullableCopiableProp<Int> = .copy
    ) -> Networking.Sys {
        let id = id ?? self.id
        let country = country ?? self.country
        let sunset = sunset ?? self.sunset
        let type = type ?? self.type
        let sunrise = sunrise ?? self.sunrise

        return Networking.Sys(
            id: id,
            country: country,
            sunset: sunset,
            type: type,
            sunrise: sunrise
        )
    }
}

extension Networking.Weather {
    public func copy(
        id: CopiableProp<Int> = .copy,
        main: NullableCopiableProp<String> = .copy,
        icon: NullableCopiableProp<String> = .copy,
        description: NullableCopiableProp<WeatherType> = .copy
    ) -> Networking.Weather {
        let id = id ?? self.id
        let main = main ?? self.main
        let icon = icon ?? self.icon
        let description = description ?? self.description

        return Networking.Weather(
            id: id,
            main: main,
            icon: icon,
            description: description
        )
    }
}

extension Networking.WeatherResponse {
    public func copy(
        coord: NullableCopiableProp<Coord> = .copy,
        weather: NullableCopiableProp<[Weather]> = .copy,
        main: NullableCopiableProp<Main> = .copy,
        name: NullableCopiableProp<String> = .copy,
        cod: NullableCopiableProp<Int> = .copy
    ) -> Networking.WeatherResponse {
        let coord = coord ?? self.coord
        let weather = weather ?? self.weather
        let main = main ?? self.main
        let name = name ?? self.name
        let cod = cod ?? self.cod

        return Networking.WeatherResponse(
            coord: coord,
            weather: weather,
            main: main,
            name: name,
            cod: cod
        )
    }
}

extension Networking.Wind {
    public func copy(
        speed: NullableCopiableProp<Double> = .copy,
        deg: NullableCopiableProp<Int> = .copy,
        gust: NullableCopiableProp<Double> = .copy
    ) -> Networking.Wind {
        let speed = speed ?? self.speed
        let deg = deg ?? self.deg
        let gust = gust ?? self.gust

        return Networking.Wind(
            speed: speed,
            deg: deg,
            gust: gust
        )
    }
}

