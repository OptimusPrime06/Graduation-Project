//
//  SegmentedBarView.swift
//  GP
//
//  Created by Gulliver Raed on 3/22/25.
//

import UIKit

final class SegmentedBarView: UIView {

    struct Model {
        let colors: [UIColor]
        let spacing: CGFloat
    }

    private var model : Model?
    
    func setModel(_ model: Model) {
            self.model = model

            subviews.forEach { $0.removeFromSuperview() }

            let views = model.colors.map {
                let view = UIView()
                view.backgroundColor = $0
                view.layer.cornerRadius = 0
                return view
            }

            views.forEach { addSubview($0) }

            setNeedsLayout()
        }
    
    // MARK: - Layout

        override func layoutSubviews() {
            super.layoutSubviews()

            guard let model,
                  !model.colors.isEmpty else { return }

            let segmentWidth = Self.calculateSegmentWidth(
                total: model.colors.count,
                spacing: model.spacing,
                width: bounds.width
            )

            var offset: CGFloat = 0

            for subview in subviews {
                subview.frame = .init(
                    x: offset,
                    y: 0,
                    width: segmentWidth,
                    height: 10
                )

                offset += segmentWidth + model.spacing
            }
        }
    
    // MARK: - Helpers

        static func calculateSegmentWidth(total: Int, spacing: CGFloat, width: CGFloat) -> CGFloat {
            guard total > 0 else { return 0 }

            let totalSpacing = CGFloat(total - 1) * spacing
            let availableWidth = width - totalSpacing
            let segmentWidth = availableWidth / CGFloat(total)

            return CGFloat.maximum(0, segmentWidth)
        }
}
