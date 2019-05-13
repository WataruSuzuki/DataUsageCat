//
//  AboutAimViewController.swift
//  DataUsageCat
//
//  Created by 鈴木 航 on 2015/06/28.
//  Copyright (c) 2015年 鈴木 航. All rights reserved.
//

/* Hello Swift, Goodbye Obj-C.
* converted by 'objc2swift' https://github.com/yahoojapan/objc2swift
* original source: AboutAimViewController.h, AboutAimViewController.m
*/

import UIKit

class AboutAimViewController: DJKAdMobBaseViewController {

    var aimType: Int = 0

    let aimTitleArray = [
        NSLocalizedString("aim_about_music", comment: ""),
        NSLocalizedString("aim_about_movie", comment: ""),
        NSLocalizedString("aim_about_webpage", comment: ""),
        NSLocalizedString("aim_about_email", comment: ""),
        NSLocalizedString("aim_about_map", comment: "")
    ]

    let aimMessageArray = [
        NSLocalizedString("aim_message_music", comment: ""),
        NSLocalizedString("aim_message_movie", comment: ""),
        NSLocalizedString("aim_message_webpage", comment: ""),
        NSLocalizedString("aim_message_email", comment: ""),
        NSLocalizedString("aim_message_map", comment: "")
    ]

    var utilNADView: DJKUtilNendAd?
    var nendBannerView: NADView!
    @IBOutlet weak var textViewAimDiscription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.initAimArray()
        
        self.title = self.aimTitleArray[aimType]
        //self.title = self.aimTitleArray.objectAtIndex(UInt(aimType!))
        textViewAimDiscription.text = self.aimMessageArray[aimType]
        //textViewAimDiscription.text = self.aimMessageArray.objectAtIndex(aimType)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.isUnlockAd {
        } else {
            if UIDevice.current.userInterfaceIdiom == .pad {
                utilNADView = delegate.utilNADView
                nendBannerView = utilNADView?.setupNendBannerView(self.view.frame, uiUserInterfaceIdiom: .phone, sizeType: SIZE_NEND_BANNER_320_50, apiKey: KeyIdAppBankSSP.KEY_BANNER_320_50, spotId: KeyIdAppBankSSP.ID_BANNER_320_50)
                self.view.addSubview(nendBannerView!)
            } else {
                addAdMobBannerView(KeyIdAdMob.BANNER_PHONE)
                DJKViewUtils.setConstraintBottomView(admobBannerView, currentAndTo: self.view)
                DJKViewUtils.setConstraintCenterX(admobBannerView, currentView: self.view)
            }
            admobInterstitial = createAndLoadAdMobInterstitial(KeyIdAdMob.INTERSTITIAL, sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        utilNADView?.notifyBannerResume(nendBannerView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if nil != admobInterstitial && admobInterstitial!.isReady {
            admobInterstitial!.present(fromRootViewController: self)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        utilNADView?.notifyBannerPause()
    }

}
