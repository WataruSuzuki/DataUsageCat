//
//  HelpingMonetizeViewController.swift
//  DataUsageCat
//
//  Created by 鈴木航 on 2019/08/28.
//  Copyright © 2019 Wataru Suzuki. All rights reserved.
//

import UIKit
import DJKPurchaseService

class HelpingMonetizeViewController: UIViewController {

    private var admobBannerView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func addAdMobBannerView(unitId: String) {
        //TODO ->
    }

    func removeAllAdBannerView() {
        admobBannerView?.removeFromSuperview()
    }
    
    func showAdMobInterstitial(unitId: String, rootViewController: UIViewController) {
        //TODO ->
    }

    func showAdMobReward(unitId: String, rootViewController: UIViewController) {
        //TODO ->
    }
}
