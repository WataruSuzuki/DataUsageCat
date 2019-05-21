//
//  DetailAboutThisAppViewController.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2016/09/10.
//  Copyright © 2016年 Wataru Suzuki. All rights reserved.
//

import UIKit

class DetailAboutThisAppViewController: HelpingMonetizeViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailTextView: UITextView!
    
    var detailImage: UIImage!
    var detailText = ""
    //TODO -> var utilNADView: DJKUtilNendAd?
    //TODO -> var nendBannerView: NADView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        detailTextView.text = detailText
        detailImageView.image = detailImage
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        setupAdBannerView(delegate: delegate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO -> utilNADView?.notifyBannerResume(nendBannerView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //TODO -> utilNADView?.notifyBannerPause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAdBannerView(delegate: AppDelegate) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            //TODO -> utilNADView = delegate.utilNADView
            //TODO -> nendBannerView = utilNADView?.setupNendBannerView(self.view.frame, uiUserInterfaceIdiom: .phone, sizeType: SIZE_NEND_BANNER_320_50, apiKey: KeyIdAppBankSSP.KEY_BANNER_320_50, spotId: KeyIdAppBankSSP.ID_BANNER_320_50)
            
            //TODO -> self.view.addSubview(nendBannerView)
        } else {
            addAdMobBannerView(unitId: KeyIdAdMob.BANNER_PHONE)
            //TODO -> DJKViewUtils.setConstraintBottomView(admobBannerView, currentAndTo: self.view)
            //TODO -> DJKViewUtils.setConstraintCenterX(admobBannerView, currentView: self.view)
        }
    }
}
