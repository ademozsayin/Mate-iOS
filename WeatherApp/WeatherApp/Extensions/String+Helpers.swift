//
//  String+Helpers.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 27.02.2024.
//

import Foundation

/// String: Helper Methods
///
extension String {

    /// Helper method to provide the singular or plural (formatted) version of a
    /// string based on a count.
    ///
    /// - Parameters:
    ///   - count: Number of 'things' in the string
    ///   - singular: Singular version of localized string — used if `count` is 1
    ///   - plural: Plural version of localized string — used if `count` is greater than 1
    /// - Returns: Singular or plural version of string based on `count` param
    ///
    /// NOTE: String params _must_ include `%ld` placeholder (count will be placed there).
    ///
    static func pluralize(_ count: Int, singular: String, plural: String) -> String {
        if count == 1 {
            return String.localizedStringWithFormat(singular, count)
        } else {
            return String.localizedStringWithFormat(plural, count)
        }
    }

    /// Helper method to provide the singular or plural (formatted) version of a
    /// string based on a count.
    ///
    /// - Parameters:
    ///   - count: Number of 'things' in the string
    ///   - singular: Singular version of localized string — used if `count` is 1
    ///   - plural: Plural version of localized string — used if `count` is greater than 1
    /// - Returns: Singular or plural version of string based on `count` param
    ///
    /// NOTE: String params _must_ include `%@` placeholder (count will be placed there).
    ///
    static func pluralize(_ count: Decimal, singular: String, plural: String) -> String {
        let stringCount = NSDecimalNumber(decimal: count).stringValue

        if count > 0 && count < 1 || count == 1 {
            return String.localizedStringWithFormat(singular, stringCount)
        } else {
            return String.localizedStringWithFormat(plural, stringCount)
        }
    }

    /// A Boolean value indicating whether a string has characters.
    var isNotEmpty: Bool {
        return !isEmpty
    }

    /// Get quotation marks from Locale
    static var quotes: (String, String) {
        guard
            let bQuote = Locale.current.quotationBeginDelimiter,
            let eQuote = Locale.current.quotationEndDelimiter
        else { return ("\"", "\"") }

        return (bQuote, eQuote)
    }

    /// Puts quotation marks at the beginning and the end of the string
    var quoted: String {
        let (bQuote, eQuote) = String.quotes
        return bQuote + self + eQuote
    }

    /// Given an string made of tags separated by commas, returns an array with these tags
    ///
    func setOfTags() -> Set<String>? {
        guard !self.isEmpty else {
            return [String()]
        }

        let arrayOfTags = self.components(separatedBy: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })

        guard !arrayOfTags.isEmpty else {
            return nil
        }

        return Set(arrayOfTags)
    }
}


/// String: Constant Helpers
///
extension String {

    /// Returns a string containing the Hair Space.
    ///
    static var hairSpace: String {
        return "\u{200A}"
    }

    /// Returns a string containing a Space.
    ///
    static var space: String {
        return " "
    }
}


/// String: URL manipulation
///
extension String {
    var hasValidSchemeForBrowser: Bool {
        hasPrefix("http://") || hasPrefix("https://")
    }

    func addHTTPSSchemeIfNecessary() -> String {
        if hasValidSchemeForBrowser {
            return self
        }

        return "https://\(self)"
    }


    /// Removes the scheme of a url
    /// - Returns: a url without scheme, or the initial string
    func trimHTTPScheme() -> String {
        guard let urlComponents = URLComponents(string: self),
              let host = urlComponents.host else {
            return self
        }

        return host + urlComponents.path
    }
}
