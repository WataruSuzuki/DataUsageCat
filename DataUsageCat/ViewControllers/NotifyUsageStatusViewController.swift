//
//  NotifyUsageStatusViewController.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2015/07/05.
//  Copyright © 2015年 Wataru Suzuki. All rights reserved.
//

/* Hello Swift, Goodbye Obj-C.
 * converted by 'objc2swift' https://github.com/yahoojapan/objc2swift
 * original source: ViewControllers/NotifyUsageStatusViewController.h, ViewControllers/NotifyUsageStatusViewController.m
 */
import UIKit

protocol NotifyUsageStatusViewControllerDelegate: class {
    func notifyUsageStatusViewControllerDidFinish(controller: NotifyUsageStatusViewController, ShowAd isShowAd: Bool)
}

class NotifyUsageStatusViewController: HelpingMonetizeViewController,
    UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableviewAboutAim: UITableView!
    @IBOutlet weak var imageUsageStatus: UIImageView!
    @IBOutlet weak var buttonUsageStatus: UIButton!
    @IBOutlet weak var textViewCommentToUsage: UITextView!
    @IBOutlet weak var labelTitlePercentage: UILabel!
    @IBOutlet weak var labelValuePercentage: UILabel!

    var userDefaultLimit: Float = 7.0
    var dataUsageCount: DUCNetworkInterFace?
    var aimTypeArray: [Double]!
    //TODO -> var utilNADView: DJKUtilNendAd?
    //TODO -> var nendBannerView: NADView?
    var statusImageFilename: String?
    
    weak var delegate: NotifyUsageStatusViewControllerDelegate?

    let AIM_STREAM_MUSIC = Double(0.154285714)
    let AIM_STREAM_MOVIE = Double(0.047142857)
    let AIM_LOAD_WEB_PAGE = Double(4.337142857)
    let AIM_USING_EMAIL = Double(201.4285714)
    let AIM_USING_MAP = Double(1.397142857)
    
    @IBAction func done(sender: AnyObject) {
        self.delegate!.notifyUsageStatusViewControllerDidFinish(controller: self, ShowAd: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.dataUsageCount = delegate.cmnuManagedObj.dataUsageCount
        let duc_ud = UtilUserDefaults()
        self.userDefaultLimit = duc_ud.limitUsageValue
        self.setViewNotifyUsageStatus()
        self.title = NSLocalizedString("comment_from_cat", comment:"")
        
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
            //TODO -> admobRewardedVideo = createAndLoadAdMobReward(KeyIdAdMob.REWARDED_VIDEO, sender: self)
        }

        self.initPercentageDisplay()
        self.initAimTypeArray()
    }

    func initPercentageDisplay() {
        labelTitlePercentage.text = NSLocalizedString("month_percentage", comment:"")
        let usageValue = UtilNetworkIF.getUsageValue(networkIf: self.dataUsageCount!)
        let usageValueGigaByte = UtilNetworkIF.calcByteData(value: usageValue, unit: UtilNetworkIF.ByteUnit.GIGA)

        labelValuePercentage.text = String(format: "%.1f", ((usageValueGigaByte / self.userDefaultLimit) * 100)) + "%"
    }

    func initAimTypeArray() {
        self.aimTypeArray = [AIM_STREAM_MUSIC, AIM_STREAM_MOVIE, AIM_LOAD_WEB_PAGE, AIM_USING_EMAIL, AIM_USING_MAP]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TODO -> utilNADView?.notifyBannerResume(nendBannerView)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //TODO -> utilNADView?.notifyBannerPause()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showAdMobInterstitial(unitId: KeyIdAdMob.INTERSTITIAL, rootViewController: self)
    }

    func setViewNotifyUsageStatus() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            imageUsageStatus.image = UIImage(named: statusImageFilename!)
        } else {
            buttonUsageStatus.setBackgroundImage(UIImage(named: statusImageFilename!), for: [])
        }
        self.setCommentToUsage(statusStr: statusImageFilename!)
    }

    func setCommentToUsage(statusStr: String) {
        let comment: String
        switch statusStr {
        case "cat_good":
            comment = NSLocalizedString("message_state_good", comment:"")
            
        case "cat_fine":
            comment = NSLocalizedString("message_state_fine", comment:"")
            
        case "cat_caution":
            comment = NSLocalizedString("message_state_caution", comment:"")
            
        case "cat_dangerous":
            comment = NSLocalizedString("message_state_dangerous", comment:"")
            
        default:
            comment = ""
        }

        textViewCommentToUsage.text = comment
    }

    func getAimValue(index: Int) -> Float {
        let usageValue = UtilNetworkIF.getUsageValue(networkIf: self.dataUsageCount!)
        let remainValue = Int64(self.userDefaultLimit * 1000 * 1000 * 1000) - usageValue
        let aimOffset = self.aimTypeArray[index]
        let aimValue = UtilNetworkIF.calcByteData(value: remainValue, unit: UtilNetworkIF.ByteUnit.MEGA) * Float(aimOffset)
        return aimValue
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return SectionNotify.MAX_SECTION_NOTIFY_USAGE.rawValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var ret: Int = 0
        switch section {
        case SectionNotify.RECOMMEND_AD.rawValue:
            let delegate = UIApplication.shared.delegate as! AppDelegate
            if !delegate.isUnlockAd {
                ret = 1
            }

        case SectionNotify.ABOUT_AIM.rawValue:
            ret = RowAboutAim.MAX_ROW_ABOUT_AIM.rawValue
            
        default:
            break
        }

        return ret
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        let aimValue = self.getAimValue(index: indexPath.row)
        switch indexPath.section {
        case SectionNotify.ABOUT_AIM.rawValue:
            cell = tableView.dequeueReusableCell(withIdentifier: "CellAboutAim", for: indexPath)
            switch indexPath.row {
            case RowAboutAim.MUSIC_STREAMING.rawValue:
                cell.textLabel!.text = NSLocalizedString("aim_about_music", comment:"")
                cell.detailTextLabel!.text = String(format: "%@ %.1f%@", NSLocalizedString("about", comment:""), aimValue, NSLocalizedString("minutes", comment:""))
                
            case RowAboutAim.MOVIE_STREAMING.rawValue:
                cell.textLabel!.text = NSLocalizedString("aim_about_movie", comment:"")
                cell.detailTextLabel!.text = String(format: "%@ %.1f%@", NSLocalizedString("about", comment:""), aimValue, NSLocalizedString("minutes", comment:""))
                
            case RowAboutAim.WEB_BROWSING.rawValue:
                cell.textLabel!.text = NSLocalizedString("aim_about_webpage", comment:"")
                cell.detailTextLabel!.text = String(format: "%@ %.1f%@", NSLocalizedString("about", comment:""), aimValue, NSLocalizedString("pages", comment:""))
                
            case RowAboutAim.EMAIL.rawValue:
                cell.textLabel!.text = NSLocalizedString("aim_about_email", comment:"")
                cell.detailTextLabel!.text = String(format: "%@ %.1f%@", NSLocalizedString("about", comment:""), aimValue, NSLocalizedString("count_time", comment:""))
                
            case RowAboutAim.MAP.rawValue:
                cell.textLabel!.text = NSLocalizedString("aim_about_map", comment:"")
                cell.detailTextLabel!.text = String(format: "%@ %.1f%@", NSLocalizedString("about", comment:""), aimValue, NSLocalizedString("count_time", comment:""))
                
            default:
                break
            }

        default:
        //case SectionNotify.RECOMMEND_AD.rawValue:
            cell = tableView.dequeueReusableCell(withIdentifier: "CellRecommendedApps", for: indexPath)
            cell.textLabel!.text = NSLocalizedString("msg_ad_recommended_title", comment:"(=・ω・=)")
            cell.detailTextLabel!.text = NSLocalizedString("msg_ad_recommended_detail", comment:"おすすめ")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SectionNotify.ABOUT_AIM.rawValue:
            return NSLocalizedString("aim", comment:"")
            
        default:
            break
        }

        return ""
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SectionNotify.RECOMMEND_AD.rawValue:
            showAdMobReward(unitId: KeyIdAdMob.REWARDED_VIDEO, rootViewController: self)

        default:
            break
        }
    }

    func prepareAboutAimViewController(segue: UIStoryboardSegue, withIndexPath indexPath: IndexPath) {
        let controller = segue.destination as! AboutAimViewController
        controller.aimType = indexPath.row
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ("AboutAimViewController") {
            let indexPath = self.tableviewAboutAim.indexPath(for: sender as! UITableViewCell)
            switch indexPath!.section {
            case SectionNotify.ABOUT_AIM.rawValue:
                self.prepareAboutAimViewController(segue: segue, withIndexPath: indexPath!)
                
            default:
                break
            }
        }
    }
    
    @IBAction func tapCat(sender: UIButton) {
        self.delegate!.notifyUsageStatusViewControllerDidFinish(controller: self, ShowAd: false)
    }

    enum SectionNotify: Int {
        case ABOUT_AIM = 0,
        RECOMMEND_AD,
        MAX_SECTION_NOTIFY_USAGE
    }
    
    enum RowAboutAim: Int {
        case MUSIC_STREAMING = 0,
        MOVIE_STREAMING,
        WEB_BROWSING,
        EMAIL,
        MAP,
        MAX_ROW_ABOUT_AIM
    }
}
