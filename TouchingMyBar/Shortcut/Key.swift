//
//  Key.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 08/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

// swiftlint:disable line_length

/// These are special keys among others, usually used to invoke shortcuts :)
/// - shift
/// - control
/// - option
/// - command
enum KeyModifier: String, Codable {
    case shift
    case control
    case option
    case command
    // TODO: Add more???
}

#warning("TODO: Figure out if ok. (Run KeyCodes app on your machine and manually check all the codes assuming US layout!)")
/// This is enum which maps the keys on the keyboard to the address which calls the action on key press.
/// Does this work universally? Or just on some keyboards?
/// Will this stay the same in future versions of MacOS?
/// See: /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
///
/// Note from @buchedom: This is probably pretty retarded. But try youreslf debug `Xcode`
///  in instruments with SIP disabled or figure out from `IDEKit` private headers how the menu items are called.
/// I bet you will find this solution pretty awesome afterwards. :D
enum Key: UInt16, Codable {
    case A = 0x00
    case B = 0x0B
    case C = 0x08
    case D = 0x02
    case E = 0x0E
    case F = 0x03
    case G = 0x05
    case H = 0x04
    case I = 0x22
    case J = 0x26
    case K = 0x28
    case L = 0x25
    case M = 0x2E
    case N = 0x2D
    case O = 0x1F
    case P = 0x23
    case Q = 0x0C
    case R = 0x0F
    case S = 0x01
    case T = 0x11
    case U = 0x20
    case V = 0x09
    case W = 0x0D
    case X = 0x07
    case Y = 0x10
    case Z = 0x06
    
    case keypad0 = 0x52
    case keypad1 = 0x53
    case keypad2 = 0x54
    case keypad3 = 0x55
    case keypad4 = 0x56
    case keypad5 = 0x57
    case keypad6 = 0x58
    case keypad7 = 0x59
    case keypad8 = 0x5B
    case keypad9 = 0x5C
    
    case keypadEqual = 0x18
    case keypadMinus = 0x1B
    case keypadPlus = 0x45
    case keypadMultiply = 0x43
    case keypadDivide = 0x4B
    
    case keypadDecimal = 0x41
    case keypadClear = 0x47
    case keypadEnter = 0x4C
    
    case rightBracket = 0x1E
    case leftBracket = 0x21
    case quote = 0x27
    case semicolon = 0x29
    case backslash = 0x2A
    case comma = 0x2B
    case slash = 0x2C
    case period = 0x2F
    case grave = 0x32 // WTF is grave???
    
    case returnKey = 0x24
    case tab = 0x30
    case space = 0x31
    case delete = 0x33
    case escape = 0x35
    // 	case command = 0x37
    // 	case shift = 0x38
    case capsLock = 0x39
    // 	case option = 0x3A
    // 	case control = 0x3B
    // 	case rightCommand = 0x36
    // 	case rightShift = 0x3C
    // 	case rightOption = 0x3D
    // 	case rightControl = 0x3E
    case function = 0x3F
    case F17 = 0x40
    case volumeUp = 0x48
    case volumeDown = 0x49
    case mute = 0x4A
    case F18 = 0x4F
    case F19 = 0x50
    case F20 = 0x5A
    case F5 = 0x60
    case F6 = 0x61
    case F7 = 0x62
    case F3 = 0x63
    case F8 = 0x64
    case F9 = 0x65
    case F11 = 0x67
    case F13 = 0x69
    case F16 = 0x6A
    case F14 = 0x6B
    case F10 = 0x6D
    case F12 = 0x6F
    case F15 = 0x71
    case help = 0x72
    case home = 0x73
    case pageUp = 0x74
    case forwardDelete = 0x75
    case F4 = 0x76
    case end = 0x77
    case F2 = 0x78
    case pageDown = 0x79
    case F1 = 0x7A
    case leftArrow = 0x7B
    case rightArrow = 0x7C
    case downArrow = 0x7D
    case upArrow = 0x7E
    
    #warning("Guess we won't be needing this anymore?")
    // swiftlint:disable:next cyclomatic_complexity
    public init?(character: Character) {
        switch character {
        case "a", "A": self = .A
        case "b", "B": self = .B
        case "c", "C": self = .C
        case "d", "D": self = .D
        case "e", "E": self = .E
        case "f", "F": self = .F
        case "g", "G": self = .G
        case "h", "H": self = .H
        case "i", "I": self = .I
        case "j", "J": self = .J
        case "k", "K": self = .K
        case "l", "L": self = .L
        case "m", "M": self = .M
        case "n", "N": self = .N
        case "o", "O": self = .O
        case "p", "P": self = .P
        case "q", "Q": self = .Q
        case "r", "R": self = .R
        case "s", "S": self = .S
        case "t", "T": self = .T
        case "u", "U": self = .U
        case "v", "V": self = .V
        case "w", "W": self = .W
        case "x", "X": self = .X
        case "y", "Y": self = .Y
        case "z", "Z": self = .Z
            
        case "0": self = .keypad0
        case "1": self = .keypad1
        case "2": self = .keypad2
        case "3": self = .keypad3
        case "4": self = .keypad4
        case "5": self = .keypad5
        case "6": self = .keypad6
        case "7": self = .keypad7
        case "8": self = .keypad8
        case "9": self = .keypad9
        
        #warning("Is there a difference between keypad = and 'normal' = ???")
            // 		case "=": self = .keypadEqual
            // 		case "-": self = .keypadMinus
            // 		case "+": self = .keypadPlus
            // 		case "*": self = .keypadMultiply
            // 		case "/": self = .keypadDivide
            // 		case "": self = .keypadDecimal
            // 		case "": self = .keypadClear
            // 		case "": self = .keypadEnter
            
        case ")": self  = .rightBracket
        case "(": self  = .leftBracket
        case "'": self  = .quote
        case ";": self  = .semicolon
        case "\\": self = .backslash
        case ",": self  = .comma
        case "/": self  = .slash
        case ".": self  = .period
            // 		case "": self = .grave
            
        default:
            preconditionFailure("Couldn't read character '\(character)'.")
            return nil
        }
    }
}