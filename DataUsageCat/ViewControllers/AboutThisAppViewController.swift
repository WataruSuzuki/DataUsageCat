//
//  AboutThisAppViewController.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2015/07/05.
//  Copyright © 2015年 Wataru Suzuki. All rights reserved.
//

import UIKit

protocol AboutThisAppViewControllerDelegate: class {
    func didFinishAboutThisApp(controller: AboutThisAppViewController)
}

class AboutThisAppViewController: HelpingMonetizeViewController,
    UITableViewDelegate, UITableViewDataSource
{

    @IBOutlet weak var textView_messageAboutThisApp: UITextView!
    @IBOutlet weak var buttonAppSettings: UIButton!
    @IBOutlet weak var tableViewAboutThisApp: UITableView!

    var storyBoardName: String!
    weak var delegate: AboutThisAppViewControllerDelegate?

    @IBAction func done(sender: AnyObject) {
        self.delegate!.didFinishAboutThisApp(controller: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("about_this_app", comment:"")
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.textView_messageAboutThisApp.text = NSLocalizedString("about_this_app_message_pad", comment:"")
        } else {
            self.textView_messageAboutThisApp.text = NSLocalizedString("about_this_app_message", comment:"")
        }
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.isUnlockAd {
        } else {
            let delay = 2.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.setupAdBannerView(delegate: delegate)
                } else {
                    self.addAdMobBannerView(unitId: KeyIdAdMob.BANNER_PHONE)
                }
            })
            loadAdMobInterstitial(unitId: KeyIdAdMob.INTERSTITIAL)
        }

        self.storyBoardName = delegate.storyBoardName
            buttonAppSettings?.setTitle(NSLocalizedString("show_app_settings", comment:""), for: [])
        
        if #available(iOS 9.0, *) {
            //Do nothing
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            self.navigationItem.leftBarButtonItem = nil
        }
    }

    func setupAdBannerView(delegate: AppDelegate) {
        //TODO -> self.view.addSubview(nendBannerView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showAdMobInterstitial(rootViewController: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        //TODO -> utilNADView?.notifyBannerPause()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuAboutThisApp.MAX.rawValue
    }
    
    // MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutThisAppCell", for: indexPath)
        
        let menu = MenuAboutThisApp(rawValue: indexPath.row)
        cell.textLabel?.text = menu?.getTitle()
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.image = menu?.getImage()
        
        return cell
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! DetailAboutThisAppViewController
        if let indexPath = self.tableViewAboutThisApp.indexPath(for: sender as! UITableViewCell) {
            let menu = MenuAboutThisApp(rawValue: indexPath.row)!
            controller.detailImage = menu.getImage()
            controller.detailText = menu.getMessage()
        }
    }
    
    enum MenuAboutThisApp: Int {
        case cat = 0,
        usageValue,
        jarashi,
        MAX
        
        func getTitle() -> String {
            switch self {
            case .cat:
                return NSLocalizedString("about_this_app_cat", comment: "")
            case .usageValue:
                return NSLocalizedString("about_this_app_usageValue", comment: "")
            case .jarashi:
                return NSLocalizedString("about_this_app_jarashi", comment: "")
            default:
                return ""
            }
        }
        
        func getMessage() -> String {
            switch self {
            case .cat:
                return NSLocalizedString("msg_about_this_app_cat", comment: "")
            case .usageValue:
                return NSLocalizedString("msg_about_this_app_usageValue", comment: "")
            case .jarashi:
                return NSLocalizedString("msg_about_this_app_jarashi", comment: "")
            default:
                return ""
            }
        }
        
        func getImage() -> UIImage {
            switch self {
            case .cat:
                return UIImage(named: "cat_good")!
            case .usageValue:
                return UIImage(named: "cat_fine")!
            case .jarashi:
                return UIImage(named: "jarashi_about")!
            default:
                return UIImage(named: "cat_dangerous")!
            }
        }
    }
}
