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
    private lazy var context = CIContext(mtlCommandQueue: commandQueue,
                                         options: [.workingFormat: CIFormat.RGBAf])
    private lazy var mtkView = MTKView()

    init() {
        super.init(frame: .zero)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    private func initialize() {
        addSubviewWithConstraints(mtkView)
        mtkView.isPaused = true
    }

}
