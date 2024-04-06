//
//  UnitInputFormatter.swift
//  Mate
//
//  Created by Adem Özsayın on 5.04.2024.
//

protocol UnitInputFormatter {
    /// Determines if the input is valid for the unit.
    ///
    func isValid(input: String) -> Bool

    /// Applies formatting to the given input string.
    ///
    func format(input: String?) -> String
}
