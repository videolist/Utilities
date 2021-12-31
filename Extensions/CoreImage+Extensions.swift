//
//  CoreImage+Extensions.swift
//  test
//
//  Created by Vadim on 12/29/21.
//

import Foundation
import CoreImage

extension CIImage {
    // MARK: - Transforms
    /**
     Transform image so that its extent starts at (0,0)
     */
    func toOrigin(_ origin: CGPoint = .zero) -> CIImage {
        transformed(by: CGAffineTransform(translationX: origin.x - extent.minX,
                                          y: origin.y - extent.minY))
    }

    /**
     Apply scale transform
     */
    func scaled(x: CGFloat, y: CGFloat) -> CIImage {
        transformed(by: CGAffineTransform(scaleX: x, y: y))
    }

    /**
     Scale uniformly in both directions
     */
    func scaledUniform(_ scale: CGFloat) -> CIImage {
        scaled(x: scale, y: scale)
    }

    /**
     Scale uniformly to make it fit into given size
     */
    func scaledAspectFit(in size: CGSize) -> CIImage {
        let scaleFactor = min(size.width / extent.width, size.height / extent.height)
        return scaledUniform(scaleFactor)
    }

    /**
     Scale uniformly to make it fill the given size
     */
    func scaledAspectFill(to size: CGSize) -> CIImage {
        let scaleFactor = max(size.width / extent.width, size.height / extent.height)
        return scaledUniform(scaleFactor)
    }

    /**
     Scale uniformly to fill the given rect and crop from center to rect size
     */
    func scaledAndCropped(filling rect: CGRect) -> CIImage {
        scaledAspectFill(to: rect.size)
            .centered(in: rect)
            .cropped(to: rect)
    }

    /**
     Scale uniformly to fit into given rect and center inside it
     */
    func scaledAndCentered(fitting rect: CGRect) -> CIImage {
        scaledAspectFit(in: rect.size)
            .centered(in: rect)
    }

    /**
     Translate image
     */
    func translated(x: CGFloat, y: CGFloat) -> CIImage {
        transformed(by: CGAffineTransform(translationX: x, y: y))
    }

    /**
     Transform image so that its center coincides with the center of the given rect
     */
    func centered(in rect: CGRect) -> CIImage {
        let shift = rect.center - extent.center
        return translated(x: shift.x, y: shift.y)
    }

    // MARK: - Chaining helpers
    /**
     Apply filter to image and return its output
     */
    func applying(filter: CIFilter?) -> CIImage? {
        filter?.setValue(self, forKey: kCIInputImageKey)
        return filter?.outputImage
    }

    // MARK: - Blending operations
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

    // MARK: - Getting colors
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
