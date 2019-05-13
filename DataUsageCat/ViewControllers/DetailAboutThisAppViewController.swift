//
//  DetailAboutThisAppViewController.swift
//  DataUsageCat
//
//  Created by 鈴木 航 on 2016/09/10.
//  Copyright © 2016年 鈴木 航. All rights reserved.
//

import UIKit

class DetailAboutThisAppViewController: DJKAdMobBaseViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailTextView: UITextView!
    
    var detailImage: UIImage!
    var detailText = ""
    var utilNADView: DJKUtilNendAd?
    var nendBannerView: NADView!

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
        
        utilNADView?.notifyBannerResume(nendBannerView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        utilNADView?.notifyBannerPause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAdBannerView(delegate: AppDelegate) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            utilNADView = delegate.utilNADView
            nendBannerView = utilNADView?.setupNendBannerView(self.view.frame, uiUserInterfaceIdiom: .phone, sizeType: SIZE_NEND_BANNER_320_50, apiKey: KeyIdAppBankSSP.KEY_BANNER_320_50, spotId: KeyIdAppBankSSP.ID_BANNER_320_50)
            
            self.view.addSubview(nendBannerView)
        } else {
            addAdMobBannerView(KeyIdAdMob.BANNER_PHONE)
            DJKViewUtils.setConstraintBottomView(admobBannerView, currentAndTo: self.view)
            DJKViewUtils.setConstraintCenterX(admobBannerView, currentView: self.view)
        }
    }
}
