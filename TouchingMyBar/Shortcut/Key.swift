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
}

///  !! US keyboard layout (qwerty) by the IDEAL standart.
/// This enum maps the keys on the keyboard to their corresponding CGKeyEvent values.
/// NOTE: There are few exceptions, like return, tab, "numRowBackTick" etc. which are layout-independent.
/// We assume these key codes stay the same in the future versions of MacOS.
/// 
/// For more info, see:
///   1) /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
///   2) https://stackoverflow.com/questions/3202629/where-can-i-find-a-list-of-mac-virtual-key-codes
///   3) use app "Key Codes" (Mac App Store)
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
    
    case numRowBackTick = 0xA // It seems like this key is present only on european layouts. On US layout, it's "grave" (0x32).
    case numRow1 = 0x12
    case numRow2 = 0x13
    case numRow3 = 0x14
    case numRow4 = 0x15
    case numRow5 = 0x17
    case numRow6 = 0x16
    case numRow7 = 0x1A
    case numRow8 = 0x1C
    case numRow9 = 0x19
    case numRow0 = 0x1D
    case numRowDash = 0x1B
    case numRowEquals = 0x18
    
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
    
//     case keypadEqual = 0x18 // Does this even exist on some keyboard nowadays?
    case keypadMinus = 0x4E
    case keypadPlus = 0x45
    case keypadMultiply = 0x43
    case keypadDivide = 0x4B
    
    case keypadPeriod = 0x41 // .
    case keypadClear = 0x47 // probably "num lock"
    case keypadEnter = 0x4C
    
    case rightBracket = 0x1E
    case leftBracket = 0x21
    case quote = 0x27
    case semicolon = 0x29
    case backslash = 0x2A
    case comma = 0x2B
    case slash = 0x2C
    case period = 0x2F
    case grave = 0x32 // on US keyboard, it's the "tilde" key (on the left of "1" above "tab"), on Czech layout, it's "\"
    
    case returnKey = 0x24
    case tab = 0x30
    case space = 0x31
    case delete = 0x33
    case escape = 0x35
    case capsLock = 0x39
//     case function = 0x3F
//     case F17 = 0x40
    case volumeUp = 0x48
    case volumeDown = 0x49
    case mute = 0x4A
//     case F18 = 0x4F
//     case F19 = 0x50
//     case F20 = 0x5A
//     case F5 = 0x60
//     case F6 = 0x61
//     case F7 = 0x62
//     case F3 = 0x63
//     case F8 = 0x64
//     case F9 = 0x65
//     case F11 = 0x67
//     case F13 = 0x69
//     case F16 = 0x6A
//     case F14 = 0x6B
//     case F10 = 0x6D
//     case F12 = 0x6F
//     case F15 = 0x71
    case help = 0x72
    case home = 0x73
    case pageUp = 0x74
    case forwardDelete = 0x75
//     case F4 = 0x76
    case end = 0x77
//     case F2 = 0x78
    case pageDown = 0x79
//     case F1 = 0x7A
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
            
        case "0": self = .numRow0
        case "1": self = .numRow1
        case "2": self = .numRow2
        case "3": self = .numRow3
        case "4": self = .numRow4
        case "5": self = .numRow5
        case "6": self = .numRow6
        case "7": self = .numRow7
        case "8": self = .numRow8
        case "9": self = .numRow9
            
//      #warning("Is there a difference between keypad = and 'normal' = ???") // oh you bet there is. FIXME
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
