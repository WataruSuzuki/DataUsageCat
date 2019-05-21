//
//  AboutAimViewController.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2015/06/28.
//  Copyright (c) 2015年 Wataru Suzuki. All rights reserved.
//

/* Hello Swift, Goodbye Obj-C.
* converted by 'objc2swift' https://github.com/yahoojapan/objc2swift
* original source: AboutAimViewController.h, AboutAimViewController.m
*/

import UIKit

class AboutAimViewController: HelpingMonetizeViewController {

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

    //TODO -> var utilNADView: DJKUtilNendAd?
    //TODO -> var nendBannerView: NADView!
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
                //TODO -> utilNADView = delegate.utilNADView
                //TODO -> nendBannerView = utilNADView?.setupNendBannerView(self.view.frame, uiUserInterfaceIdiom: .phone, sizeType: SIZE_NEND_BANNER_320_50, apiKey: KeyIdAppBankSSP.KEY_BANNER_320_50, spotId: KeyIdAppBankSSP.ID_BANNER_320_50)
                //TODO -> self.view.addSubview(nendBannerView!)
            } else {
                addAdMobBannerView(unitId: KeyIdAdMob.BANNER_PHONE)
                //TODO -> DJKViewUtils.setConstraintBottomView(admobBannerView, currentAndTo: self.view)
                //TODO -> DJKViewUtils.setConstraintCenterX(admobBannerView, currentView: self.view)
            }
            //TODO -> admobInterstitial = createAndLoadAdMobInterstitial(KeyIdAdMob.INTERSTITIAL, sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TODO -> utilNADView?.notifyBannerResume(nendBannerView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showAdMobInterstitial(unitId: KeyIdAdMob.INTERSTITIAL, rootViewController: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //TODO -> utilNADView?.notifyBannerPause()
    }

}
