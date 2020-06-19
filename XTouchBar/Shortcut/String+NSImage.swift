//
//  String+UIImage.swift
//  XTouchBar
//
//  Created by Dominik Bucher on 19/06/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Cocoa

// All credit goes to https://gist.github.com/ericdke/b10335b2dee0e4fc58949a0e8a8ef722
// Thank you for not wasting my time :D
extension String {

    // https://stackoverflow.com/a/36258684/2227743
    var containsEmoji: Bool {
        for scalar in self.unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x2600...0x26FF,   // Misc symbols
            0x2700...0x27BF,   // Dingbats
            0xFE00...0xFE0F,   // Variation Selectors
            0x1F900...0x1F9FF:  // Supplemental Symbols and Pictographs
                return true
            default:
                continue
            }
        }
        return false
    }

    // Idea and original code by Daniel Jalkut http://indiestack.com/2017/06/evergreen-images/
    // Converted to a Swift 4 String extension by https://github.com/ericdke
    func emojiImage(width: Int = 1024, height: Int = 1024) -> NSImage? {
        guard width > 24,
              !self.isEmpty,
              self.containsEmoji,
              let first = self.first,
              let drawingContext = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
          )
        else { return nil }

        let imageSize = NSSize(width: width, height: height)
        let targetRect = NSRect(origin: .zero, size: imageSize)
        let font = NSFont.systemFont(ofSize: CGFloat(width - 24))
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: drawingContext, flipped: false)
        NSString(string: String(first)).draw(in: targetRect, withAttributes: [.font: font])
        NSGraphicsContext.restoreGraphicsState()
        if let coreImage = drawingContext.makeImage() {
          return NSImage(cgImage: coreImage, size: imageSize)
        }
        return nil
    }

}
