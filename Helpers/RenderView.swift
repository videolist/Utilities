//
//  RenderView.swift
//  BlogCompanion
//
//  Created by Vadim on 12/30/21.
//

import UIKit
import MetalKit

class RenderView: UIView {

    private lazy var device = MTLCreateSystemDefaultDevice()!
    private lazy var commandQueue = device.makeCommandQueue()!
    private lazy var context = CIContext(mtlDevice: device,
                                         options: [.cacheIntermediates: false])
    private lazy var mtkView = MTKView(frame: .zero, device: device)

    init() {
        super.init(frame: .zero)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    var image: CIImage? {
        didSet {
            mtkView.setNeedsDisplay()
        }
    }

    private func initialize() {
        addSubviewWithConstraints(mtkView)
        mtkView.enableSetNeedsDisplay = true
        mtkView.framebufferOnly = false
        mtkView.autoResizeDrawable = true
        mtkView.backgroundColor = .clear
        mtkView.isPaused = true
        mtkView.delegate = self
    }

}

extension RenderView: MTKViewDelegate {

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        view.setNeedsDisplay()
    }

    func draw(in view: MTKView) {
        guard image != nil else { return }

        let destination = CIRenderDestination(width: Int(view.drawableSize.width),
                                              height: Int(view.drawableSize.height),
                                              pixelFormat: view.colorPixelFormat,
                                              commandBuffer: nil) {
            view.currentDrawable!.texture
        }
        destination.alphaMode = .premultiplied

        defer {
            let commandBuffer = commandQueue.makeCommandBuffer()
            commandBuffer?.present(view.currentDrawable!)
            commandBuffer?.commit()
        }

        _ = try? context.startTask(toClear: destination)
        let displayRect = CGRect(origin: .zero, size: view.drawableSize)

        guard let image = image?.scaledAndCentered(fitting: displayRect) else {
            return
        }
        _ = try? context.startTask(toRender: image,
                                   from: image.extent,
                                   to: destination,
                                   at: image.extent.origin)


    }

}
