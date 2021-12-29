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
     Blend image over background using suplied alpha mask image.
     - When the mask alpha value is 0.0, the result is the background.
     - When the mask alpha value is 1.0, the result is the image.
     */
    func blending(with backgroundImage: CIImage, alphaMask: CIImage) -> CIImage {
        applyingFilter("CIBlendWithAlphaMask",
                       parameters: [
                        kCIInputBackgroundImageKey: backgroundImage,
                        kCIInputMaskImageKey: alphaMask
                       ])
    }
}
