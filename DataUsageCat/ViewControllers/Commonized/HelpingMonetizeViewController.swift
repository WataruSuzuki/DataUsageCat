//
//  HelpingMonetizeViewController.swift
//  DataUsageCat
//
//  Created by 鈴木航 on 2019/08/28.
//  Copyright © 2019 Wataru Suzuki. All rights reserved.
//

import UIKit
import DJKPurchaseService
import PureLayout

class HelpingMonetizeViewController: UIViewController {

    private var admobBannerView: UIView?
    
    func addAdMobBannerView(unitId: String, toItem: UIView? = nil) {
        if admobBannerView == nil {
            admobBannerView = PurchaseService.shared.bannerView(unitId: unitId, rootViewController: self)
            if let toItem = toItem {
                toItem.addSubview(admobBannerView!)
                admobBannerView?.autoPinEdge(toSuperviewEdge: .bottom)
            } else {
                view.addSubview(admobBannerView!)
                admobBannerView?.autoPinEdge(toSuperviewSafeArea: .bottom)
            }
            admobBannerView?.autoAlignAxis(toSuperviewAxis: .vertical)
        }
    }

    func removeAllAdBannerView() {
        admobBannerView?.removeFromSuperview()
        admobBannerView = nil
    }
    
    func loadAdMobInterstitial(unitId: String) {
        PurchaseService.shared.loadInterstitial(unitId: unitId)
    }
    
    func loadAdMobReward(unitId: String) {
        PurchaseService.shared.loadReward(unitId: unitId)
    }

    func showAdMobInterstitial(rootViewController: UIViewController) {
        PurchaseService.shared.showInterstitial(rootViewController: rootViewController)
    }

    func showAdMobReward(rootViewController: UIViewController) {
        PurchaseService.shared.showReward(rootViewController: rootViewController)
    }
}
