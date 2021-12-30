//
//  CoreImage+Extensions.swift
//  test
//
//  Created by Vadim on 12/29/21.
//

import Foundation
import CoreImage

extension CIImage {
    /**
     Blend reciever over background using suplied alpha mask image.
     - When the mask alpha value is 0.0, the result is the background.
     - When the mask alpha value is 1.0, the result is the image (the reciever).
     */
    func blending(over backgroundImage: CIImage, alphaMask: CIImage) -> CIImage {
        applyingFilter("CIBlendWithAlphaMask",
                       parameters: [
                        kCIInputBackgroundImageKey: backgroundImage,
                        kCIInputMaskImageKey: alphaMask
                       ])
    }

    /**
     Blend supplied image over receiver using suplied alpha mask image.
     - When the mask alpha value is 0.0, the result is the receiver.
     - When the mask alpha value is 1.0, the result is the supplied image.
     */
    func blending(with image: CIImage, alphaMask: CIImage) -> CIImage {
        image.applyingFilter("CIBlendWithAlphaMask",
                       parameters: [
                        kCIInputBackgroundImageKey: self,
                        kCIInputMaskImageKey: alphaMask
                       ])
    }

    /**
     Apply filter to image and return its output
     */
    func applying(filter: CIFilter?) -> CIImage? {
        filter?.setValue(self, forKey: kCIInputImageKey)
        return filter?.outputImage
    }

    /**
     Read pixel colors from 1-pixel high image.
     - Returns nil if image's height is bigger than 1 to avoid reading large amounts of data
     - Returned array will contain colors of pixels from left to right
     */
    func rowOfPixelsToColors(makeOpqaue: Bool = false) -> [CIColor]? { // 1
        guard extent.height == 1 else { return nil }                // 2
        let image = makeOpqaue ? settingAlphaOne(in: extent) : self // 3

        let rowComponents = Int(extent.width) * 4
        let rowBytes = rowComponents * 4
        let bufferPtr = UnsafeMutablePointer<Float32>.allocate(capacity: rowComponents)

        CIContext(options: [.workingColorSpace: NSNull()]) // 4
            .render(image,
                    toBitmap: bufferPtr,
                    rowBytes: rowBytes,
                    bounds: extent,
                    format: .RGBAf,     // 5
                    colorSpace: nil)    // 6

        defer {
            bufferPtr.deallocate()      // 7
        }
        return stride(from: 0, to: rowComponents, by: 4).map {
            let components = ($0...$0+3).map { CGFloat(bufferPtr[$0])}
            return CIColor(red: components[0],
                           green: components[1],
                           blue: components[2],
                           alpha: components[3])
        }
    }
}
