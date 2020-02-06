//
//  TopCollectionViewCell.swift
//  DataUsageCat
//
//  Created by WataruSuzuki on 2020/03/28.
//  Copyright © 2020 WataruSuzuki. All rights reserved.
//

import UIKit

class TopCollectionViewCell: UICollectionViewCell {
    private var subContentView: UIView?
    private var subContentViewConstraints = [NSLayoutConstraint]()

    func setContent(view: UIView) {
        self.contentView.addSubview(view)
        self.contentView.autoPinEdgesToSuperviewEdges()
        
        self.subContentView = view
        updateDimensions()
        view.autoCenterInSuperview()
    }
    
    override func layoutSubviews() {
        updateDimensions()
        
        super.layoutSubviews()
    }
    
    private func updateDimensions() {
        guard let view = subContentView else { return }
        view.removeConstraints(subContentViewConstraints)
        subContentViewConstraints.removeAll()
        
        subContentViewConstraints.append(
            view.autoSetDimension(.width, toSize: self.frame.width)
        )
        subContentViewConstraints.append(
            view.autoSetDimension(.height, toSize: self.frame.height)
        )
    }
}
