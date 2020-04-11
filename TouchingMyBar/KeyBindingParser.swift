//
//  KeyBindingParser.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 11/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Foundation

/// Is actually delegate but I hate the delegate pattern so much that I call this juts idiot. Because only idiot listens to others and does as they command.
class ParserIdiot: NSObject, XMLParserDelegate {

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:]) {

        if elementName == "key" {
            print(elementName)
        }

        if qName == "Keyboard Shortcut" {
            print(qName)
        }
    }

}

class KeyBindingProvider {
    typealias Path = String

    private var parser: XMLParser
    private var idiot = ParserIdiot()

    public init(with resourcePath: Path) {
        parser = XMLParser(contentsOf: URL(string: resourcePath)!)!
        parser.delegate = idiot
        parser.parse()
    }
}
