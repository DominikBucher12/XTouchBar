//
//  Key.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 08/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

#warning("TODO: Figure out if ok.")
// Does this work universally? Or just on some keyboards?
// Will this stay the same in future versions of MacOS?
// See: /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
enum Key: UInt16 {
    case A              = 0x00
    case B              = 0x0B
    case C              = 0x08
    case D              = 0x02
    case E              = 0x0E
    case F              = 0x03
    case G              = 0x05
    case H              = 0x04
    case I              = 0x22
    case J              = 0x26
    case K              = 0x28
    case L              = 0x25
    case M              = 0x2E
    case N              = 0x2D
    case O              = 0x1F
    case P              = 0x23
    case Q              = 0x0C
    case R              = 0x0F
    case S              = 0x01
    case T              = 0x11
    case U              = 0x20
    case V              = 0x09
    case W              = 0x0D
    case X              = 0x07
    case Y              = 0x10
    case Z              = 0x06
    
    case keypad0        = 0x52
    case keypad1        = 0x53
    case keypad2        = 0x54
    case keypad3        = 0x55
    case keypad4        = 0x56
    case keypad5        = 0x57
    case keypad6        = 0x58
    case keypad7        = 0x59
    case keypad8        = 0x5B
    case keypad9        = 0x5C
    
    case keypadEqual    = 0x18
    case keypadMinus    = 0x1B
    case keypadPlus     = 0x45
    case keypadMultiply = 0x43
    case keypadDivide   = 0x4B
    
    case keypadDecimal  = 0x41
    case keypadClear    = 0x47
    case keypadEnter    = 0x4C
    
    case rightBracket   = 0x1E
    case leftBracket    = 0x21
    case quote          = 0x27
    case semicolon      = 0x29
    case backslash      = 0x2A
    case comma          = 0x2B
    case slash          = 0x2C
    case period         = 0x2F
    case grave          = 0x32 // WTF is grave???
}
