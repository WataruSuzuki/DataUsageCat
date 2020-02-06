//
//  String+Snakenized.swift
//  SwiftExtensionChimera
//
//  Created by WataruSuzuki on 2020/04/01.
//  Copyright © 2019 WataruSuzuki. All rights reserved.
//

import Foundation

extension String {
    public var snakenized: String {
        // Ensure the first letter is capital
        let head = String(prefix(1))
        let tail = String(suffix(count - 1))
        let upperCased = head.uppercased() + tail

        let input = upperCased

        // split input string into words with Capital letter
        let pattern = "[A-Z]+[a-z,\\d]*"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return ""
        }

        var words:[String] = []

        regex.matches(in: input, options: [], range: NSRange.init(location: 0, length: count)).forEach { match in
            if let range = Range(match.range(at: 0), in: self) {
                words.append(String(self[range]).lowercased())
            }
        }

        return words.joined(separator: "_")
    }
}

