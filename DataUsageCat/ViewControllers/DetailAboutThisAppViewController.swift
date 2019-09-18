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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        detailTextView.text = detailText
        detailImageView.image = detailImage
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        setupAdBannerView(delegate: delegate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAdBannerView(delegate: AppDelegate) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            //TODO -> self.view.addSubview(nendBannerView)
        } else {
            addAdMobBannerView(unitId: KeyIdAdMob.BANNER_PHONE)
                                }
    }
}
