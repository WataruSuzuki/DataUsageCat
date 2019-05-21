//
//  MainViewController.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2015/07/04.
//  Copyright © 2015年 Wataru Suzuki. All rights reserved.
//

/* Hello Swift, Goodbye Obj-C.
* converted by 'objc2swift' https://github.com/yahoojapan/objc2swift
* original source: MainViewController.h, MainViewController.m
*/

import UIKit
import CoreData
import BubbleTransition
import RMPZoomTransitionAnimator
import DJKPurchaseService

class MainViewController: CommonUtilChartScrollViewController,
    AboutThisAppViewControllerDelegate,
    SettingsViewControllerDelegate,
    NotifyUsageStatusViewControllerDelegate,
    SummaryNetworkUsageTableViewControllerDelegate,
    //ADGManagerViewControllerDelegate, ADGInterstitialDelegate,
    UIViewControllerTransitioningDelegate,
    UIPopoverControllerDelegate
{
    let bubbleTransition = BubbleTransition()
    let zoomTransitionAnimator = RMPZoomTransitionAnimator()
    
    var needleAngle: Float = OFFSET_START_ANGLE
    //var myPopoverController: UIPopoverController?
    var statusImageFilename: String = UsageProgessStats.GOOD.getStatusPartsName()
    //TODO -> var utilNADView: DJKUtilNendAd?
    //var adgMngr: ADGManagerViewController?
    var dataUsageCount: DUCNetworkInterFace?
    var isPrepareShowDayUsage: Bool = false
    
    private let privacyPolicyUrl = "https://github.com/WataruSuzuki/DataUsageCat/blob/master/PRIVACY_POLICY.md"
    
    //@IBOutlet var iAd_BannerView: ADBannerView!
    @IBOutlet weak var meterNeedleImage: UIImageView!
    @IBOutlet weak var buttonTopCatStatusImage: UIButton!
    @IBOutlet weak var imageMeterBackGround: UIImageView!
    @IBOutlet weak var buttonCurrentMonthValue: UIButton!
    @IBOutlet weak var titleMonthValueLabel: UILabel?
    @IBOutlet weak var labelMonthValueUnit: UILabel!
    @IBOutlet weak var viewUsageResultArea: UIView!
    @IBOutlet weak var barButtonAboutThisApp: UIBarButtonItem!
    @IBOutlet weak var barButtonSettings: UIBarButtonItem!
    @IBOutlet weak var segmentDataUsageType: UISegmentedControl!
    @IBOutlet weak var adConstraintView: UIView!
    @IBOutlet weak var meterNeedleButtonBgView: UIView!
    @IBOutlet weak var meterNeedleButton: UIButton!

    override func viewDidLoad() {
        //setupPersonalizedAdConsent()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.mainViewControllerWillAppear), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        if .pad == UIDevice.current.userInterfaceIdiom {
            imageMeterBackGround.image = UIImage(named: "meter_bg")
            barButtonAboutThisApp.title = NSLocalizedString("about_this_app", comment:"")
            barButtonSettings.title = NSLocalizedString("app_settings", comment:"")
            self.initPadUsageDispArea(view: viewUsageResultArea, withColor: UIColor.gray.cgColor)
            self.initPadUsageDispArea(view: weekChartScrollView, withColor: self.getDucGreenCgColor())
            self.initPadUsageDispArea(view: selectedDayScrollView, withColor: UIColor.gray.cgColor)
        } else {
            meterNeedleButton?.setTitle("", for: [])
        }
        
        self.needleAngle = OFFSET_START_ANGLE
        self.setInitViewImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mainViewControllerWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.setupChartScrollViews()
        }
    }
    
    func checkPermissions() {
        let delay: Double
        if #available(iOS 10.0, *) {
            checkNotificationAuthorization()
            delay = 3.0 * Double(NSEC_PER_SEC)
        } else {
            delay = 24.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + delay / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                Thread.detachNewThreadSelector(#selector(MainViewController.checkNotificationAuthorization), toTarget:self, with: nil)
            })
        }
    }
    
    @objc func checkNotificationAuthorization() {
        let utilNotification = UtilLocalNotification()
        utilNotification.getNotificationPermittedStatus { (isPermitted) in
            if isPermitted {
                utilNotification.showConfirmNotificationPermission()
            }
        }
    }
    
    func fitPadChartArea() {
        self.setupChartScrollViews()
        self.gotoSelectedDayPage(animated: false, withPage: self.currentDayPage)
    }
    
    @objc func mainViewControllerWillAppear() {
        guard self == self.navigationController?.topViewController else {
            return
        }
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let duc_ud = UtilUserDefaults()
        self.userDefaultLimit = duc_ud.limitUsageValue
        delegate.cmnuManagedObj.fetchMonthNetworkUsage(context: delegate.cmnuManagedObj.managedObjectContext)
        dataUsageCount = delegate.cmnuManagedObj.dataUsageCount
        if #available(iOS 10.0, *) {
            UtilLocalNotification().catRestartDataMonitoring()
        }
        
        setupAdMob()
        
        self.setViewTitle()
        self.setNeedlePosition()
        self.checkPermissions()
    }
    
    private func setupAdMob() {
        PurchaseService.shared.confirmPersonalizedConsent(publisherIds: [KeyIdAdMob.PUBLISHER_ID], privacyPolicyUrl: privacyPolicyUrl) { (success) in
            if success {
                //GADMobileAds.sharedInstance().start(completionHandler: nil)

                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.updateViewUsageResult(size: self.view.frame.size, orientation: UIApplication.shared.statusBarOrientation)
                    self.setupUsageDataForChart()
                    self.updateAllAdBannerView()
                    //TODO -> admobInterstitial = createAndLoadAdMobInterstitial(KeyIdAdMob.INTERSTITIAL, sender: self)
                } else {
                    self.navigationController?.isNavigationBarHidden = true
                    self.updateAllAdBannerView()
                }
            }
        }
    }

    func resumeOtherAdView(delegate: AppDelegate) {
        if delegate.isUnlockAd {
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.needleAngle = OFFSET_START_ANGLE
        self.setInitViewImage()
    }
    
    func updateViewUsageResult(size: CGSize, orientation: UIInterfaceOrientation) {
        let collection = UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.regular)
        if traitCollection.containsTraits(in: collection) {
            // Regular size
        } else {
            // Compact size
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.weekChartScrollView.isHidden = true
        self.selectedDayScrollView.isHidden = true
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.updateViewUsageResult(size: size, orientation: UIApplication.shared.statusBarOrientation)
            
            for view in self.selectedDayScrollView.subviews {
                view.removeFromSuperview()
            }
            }, completion: { (context) -> Void in
                self.fitPadChartArea()
                if 0 > self.currentDayPage {
                    //do nothing
                } else {
                    self.weekChartScrollView.isHidden = false
                    self.selectedDayScrollView.isHidden = false
                }
        })
    }
    
    func setNeedlePosition() {
        let usermax = self.userDefaultLimit
        let savingUsageValue = UtilNetworkIF.getWifiDataUsageByGigaByte(dataUsage: dataUsageCount!)
        let usageValue = UtilNetworkIF.getCellularDataUsageByGigaByte(dataUsage: dataUsageCount!)
        self.startAnimationMeterNeedle(dataUsage: usageValue, DurationTime: TIME_DELAY_1SECOND)
        let num = NSNumber(value: usageValue)
        let delay = Double(TIME_DELAY_1SECOND) * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            self.updateTopUsageStatus(num: num)
        })
        self.setCurrentMonthValueLabelAndButton(usermax: usermax, andWifiUsage: savingUsageValue, andCellularUsage: usageValue)
    }
    
    func setCurrentMonthValueLabelAndButton(usermax: Float, andWifiUsage savingUsageValue: Float, andCellularUsage usageValue: Float) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.setDataUsageValueText(index: SegmentType.USAGE.rawValue, andUserMax: usermax, andWifiUsage: savingUsageValue, andCellularUsage: usageValue)
            self.setDataUsageValueText(index: SegmentType.REMAIN.rawValue, andUserMax: usermax, andWifiUsage: savingUsageValue, andCellularUsage: usageValue)
            self.setDataUsageValueText(index: SegmentType.SAVE.rawValue, andUserMax: usermax, andWifiUsage: savingUsageValue, andCellularUsage: usageValue)
        }
        
        self.setDataUsageValueText(index: segmentDataUsageType.selectedSegmentIndex, andUserMax: usermax, andWifiUsage: savingUsageValue, andCellularUsage: usageValue)
    }
    
    func setDataUsageValueText(index: Int, andUserMax usermax: Float, andWifiUsage savingUsageValue: Float, andCellularUsage usageValue: Float) {
        let segmentType = SegmentType(rawValue: index)
        let titleStr = (segmentType?.toString())!
        
        var remainValue: Float = (usermax - usageValue)
        if 0 > remainValue {
            remainValue = 0
        }
        
        titleMonthValueLabel?.text = titleStr
        switch index {
        case SegmentType.USAGE.rawValue:
            buttonCurrentMonthValue.setTitle(String(format: "%.1f", usageValue), for: [])
            
        case SegmentType.REMAIN.rawValue:
            buttonCurrentMonthValue.setTitle(String(format: "%.1f", remainValue), for: [])
            
        case SegmentType.SAVE.rawValue:
            buttonCurrentMonthValue.setTitle(String(format: "%.1f", savingUsageValue), for: [])
            
        default:
            break
        }
    }
    
    func setViewTitle() {
        titleMonthValueLabel?.text = SegmentType.USAGE.toString()
        segmentDataUsageType.setTitle(SegmentType.USAGE.toString(), forSegmentAt: SegmentType.USAGE.rawValue)
        segmentDataUsageType.setTitle(SegmentType.REMAIN.toString(), forSegmentAt: SegmentType.REMAIN.rawValue)
        segmentDataUsageType.setTitle(SegmentType.SAVE.toString(), forSegmentAt: SegmentType.SAVE.rawValue)
    }
    
    func setInitViewImage() {
        buttonTopCatStatusImage.setBackgroundImage(UIImage(named: "cat_good"), for: [])
        meterNeedleImage.image = UIImage(named: "jarashi_good")
        let affine = (2 * .pi * Double(self.needleAngle) / 360.0 - 0.000001)
        self.meterNeedleImage.transform = CGAffineTransform(rotationAngle: CGFloat(affine))
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.meterNeedleButtonBgView.transform = CGAffineTransform(rotationAngle: CGFloat(affine))
        }
    }
    
    func startAnimationMeterNeedle(dataUsage: Float, DurationTime durationTime: Float) {
        let usermax = self.userDefaultLimit
        var angleValue: Float = (dataUsage - usermax / 2) * (ADJUST_ANGLE / (usermax / 2))
        if OFFSET_START_ANGLE > angleValue {
            angleValue = OFFSET_START_ANGLE
        } else if ADJUST_ANGLE < angleValue {
            angleValue = ADJUST_ANGLE
        } else {
            //do nothing
        }
        
        UIView.animate(withDuration: TimeInterval(durationTime), animations: { () -> Void in
            self.needleAngle = angleValue
            let affine = (2 * .pi * Double(self.needleAngle) / 360.0 - 0.000001)
            //let affine = (2*M_PI*Double(self.needleAngle)/360.0-0.000001)
            self.meterNeedleImage.transform = CGAffineTransform(rotationAngle: CGFloat(affine))
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.meterNeedleButtonBgView.transform = CGAffineTransform(rotationAngle: CGFloat(affine))
            }
        })
    }
    
    func updateTopUsageStatus(num: NSNumber) {
        let usermax = self.userDefaultLimit
        let usageValue = num.floatValue
        
        if let progStatus = UsageProgessStats(rawValue: getUsageProgressStatus(usageValue: usageValue, withUserMax: usermax)) {
            statusImageFilename = (progStatus.getStatusPartsName())
            
            buttonTopCatStatusImage.setBackgroundImage(UIImage(named: statusImageFilename), for: [])
            meterNeedleImage.image = UIImage(named: progStatus.getJarashiName())
        }
    }
    
    func getUsageProgressStatus(usageValue: Float, withUserMax usermax: Float) -> Int {
        let ret: Int
        if usageValue > (usermax * 0.75) {
            ret = UsageProgessStats.DANGEROUS.rawValue
        } else if usageValue > (usermax * 0.5) {
            ret = UsageProgessStats.CAUTION.rawValue
        } else if usageValue > (usermax * 0.25) {
            ret = UsageProgessStats.FINE.rawValue
        } else {
            ret = UsageProgessStats.GOOD.rawValue
        }
        
        return ret
    }
    
    func settingsViewControllerDidFinish(controller: SettingsViewController) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.updateAllAdBannerView()
            showInterstitialAdDependingOnTheConditions(isForce: false)
        }
    }
    
    func didFinishAboutThisApp(controller: AboutThisAppViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showInterstitialAdDependingOnTheConditions(isForce: Bool) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let isShowTime = (isForce || 0 == (delegate.countAdMobInterstitial % 10))
        
        showAdMobInterstitial(unitId: KeyIdAdMob.INTERSTITIAL, rootViewController: self)

        if !isForce {
            delegate.countAdMobInterstitial += 1
        }
    }
    
    func popoverPresentControllerDidFinish(isShowAd: Bool) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.dismiss(animated: true, completion: nil)
        } else {
            if isShowAd {
                let delay = Double(TIME_DELAY_1SECOND) * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    Thread.detachNewThreadSelector(#selector(MainViewController.delayShowAd), toTarget:self, with: nil)
                })
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func notifyUsageStatusViewControllerDidFinish(controller: NotifyUsageStatusViewController, ShowAd isShowAd: Bool) {
        popoverPresentControllerDidFinish(isShowAd: isShowAd)
    }
    
    func summaryNetworkUsageTableViewControllerDidFinish(controller: SummaryNetworkUsageTableViewController, ShowAd isShowAd: Bool) {
        popoverPresentControllerDidFinish(isShowAd: isShowAd)
    }
    
    @objc func delayShowAd() {
        showInterstitialAdDependingOnTheConditions(isForce: true)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return startTransition(forPresented: presented, presenting: presenting, source: source)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition(forDismissed: dismissed)
    }
    
    func startTransition(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let navigationController = presented as! UINavigationController
        if let destination = navigationController.viewControllers.last {
                bubbleTransition.transitionMode = .present
            bubbleTransition.startingPoint = getStartPoint(destination: destination)
                bubbleTransition.bubbleColor = UIColor.white//getDucGreenColor()
                return bubbleTransition
        }
        return nil
    }
    
    func dismissTransition(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let navigationController = dismissed as! UINavigationController
        if let destination = navigationController.viewControllers.last {
                bubbleTransition.transitionMode = .dismiss
            bubbleTransition.startingPoint = getStartPoint(destination: destination)
                bubbleTransition.bubbleColor = UIColor.white//getDucGreenColor()
                return bubbleTransition
                
        }
        return nil
    }
    
    func getStartPoint(destination: UIViewController) -> CGPoint {
        if type(of: destination) === NotifyUsageStatusViewController.self {
            return buttonTopCatStatusImage.center
        } else if type(of: destination) === DetailThisMonthUsageViewController.self {
            return buttonCurrentMonthValue.center
        } else {
            return self.view.center
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard !preparePush(for: segue, sender: sender) else {
            return
        }
        
        let navigationController = segue.destination as! UINavigationController
        
        if #available(iOS 9.0, *) {
            //do nothing
        } else {
            let popoverController: UIPopoverController?
            if let popoverSegue = segue as? UIStoryboardPopoverSegue {
                popoverController = popoverSegue.popoverController
                popoverController!.delegate = self
            }
        }
        switch segue.identifier! {
        case "DetailThisMonthUsageViewController":
            navigationController.transitioningDelegate = self
            navigationController.modalPresentationStyle = .custom

        case "NotifyUsageStatusViewController":
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popPresent = navigationController.popoverPresentationController {
                    popPresent.sourceView = buttonTopCatStatusImage.superview
                    popPresent.sourceRect = buttonTopCatStatusImage.frame
                }
            } else {
                navigationController.transitioningDelegate = self
                navigationController.modalPresentationStyle = .custom
            }

            let controller = navigationController.viewControllers.last as! NotifyUsageStatusViewController
            controller.statusImageFilename = statusImageFilename
            controller.delegate = self
            
        case "SummaryNetworkUsageTableViewController":
            let controller = navigationController.viewControllers.last as! SummaryNetworkUsageTableViewController
            if isPrepareShowDayUsage {
                prepareShowSummaryNetworkUsage(controller: controller)
            } else {
                controller.networkIF = dataUsageCount
            }
            controller.delegate = self
            self.isPrepareShowDayUsage = false
            
        case "SettingsViewController":
            let controller = navigationController.viewControllers.last as! SettingsViewController
            controller.delegate = self
            
        case "showFlipside":
            let controller = navigationController.viewControllers.last as! AboutThisAppViewController
            controller.delegate = self
            
        default:
            break
        }
    }
    
    func preparePush(for segue: UIStoryboardSegue, sender: Any?) -> Bool {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return false
        }
        switch segue.identifier! {
        case "showFlipside":
            if let controller = segue.destination as? AboutThisAppViewController {
                controller.delegate = self
                navigationController?.isNavigationBarHidden = !(navigationController?.isNavigationBarHidden)!
                return true
            }
            fallthrough
            
        default:
            break
        }
        return false
    }
    
    func updateAllAdBannerView() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.isUnlockAd {
            self.removeAllAdBannerView()
        } else {
            self.updateAdMobBannerView()
        }
    }
    
    func updateAdMobBannerView() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            addAdMobBannerView(unitId: KeyIdAdMob.BANNER_PAD)
            //TODO -> DJKViewUtils.setConstraintBottomView(admobBannerView, currentAndTo: self.view)
        } else {
            addAdMobBannerView(unitId: KeyIdAdMob.BANNER_PHONE)
            //TODO -> DJKViewUtils.setConstraintBottomView(admobBannerView, toItem: adConstraintView, currentView: self.view)
        }
        //TODO -> DJKViewUtils.setConstraintCenterX(admobBannerView, currentView: self.view)
    }
    
    func getDucGreenCgColor() -> CGColor {
        return getDucGreenColor().cgColor
    }
    
    func getDucGreenColor() -> UIColor {
        return UIColor(red: 0, green: 0.392, blue: 0, alpha: 1.0)
    }
    
    func initPadUsageDispArea(view: UIView, withColor cgColor: CGColor) {
        if 0 > self.currentDayPage {
            //Do nothing because no usage data.
        } else {
            view.layer.borderColor = (cgColor)
            view.layer.borderWidth = (2.0)
            view.backgroundColor = (UIColor.clear)
        }
    }

    @IBAction func togglePopover(sender: AnyObject) {
        self.performSegue(withIdentifier: "showFlipside", sender: sender)
    }
    
    @IBAction func tapSegmentDataUsageType(sender: AnyObject) {
        let usermax = self.userDefaultLimit
        let savingUsageValue = UtilNetworkIF.getWifiDataUsageByGigaByte(dataUsage: dataUsageCount!)
        let usageValue = UtilNetworkIF.getCellularDataUsageByGigaByte(dataUsage: dataUsageCount!)
        self.setCurrentMonthValueLabelAndButton(usermax: usermax, andWifiUsage: savingUsageValue, andCellularUsage: usageValue)
    }
    
    override func tapSummaryNetworkUsage(sender: AnyObject) {
        isPrepareShowDayUsage = true
        self.performSegue(withIdentifier: "SummaryNetworkUsageTableViewController", sender: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    enum SegmentType : Int {
        case USAGE = 0,
        REMAIN,
        SAVE,
        MAX_SEGMENT_TYPE
        
        func toString() -> String {
            switch self {
            case SegmentType.USAGE:
                return NSLocalizedString("month_usage", comment:"")
            case SegmentType.REMAIN:
                return NSLocalizedString("month_remain", comment:"")
            case SegmentType.SAVE:
                return NSLocalizedString("month_save", comment:"")
            default:
                return ""
            }
        }
    }
    
    enum UsageProgessStats : Int {
        case GOOD = 0,
        FINE,
        CAUTION,
        DANGEROUS
        
        func getStatusPartsName() -> String {
            switch self {
            case UsageProgessStats.DANGEROUS:
                return "cat_dangerous"
            case UsageProgessStats.CAUTION:
                return "cat_caution"
            case UsageProgessStats.FINE:
                return "cat_fine"
            case UsageProgessStats.GOOD:
                return "cat_good"
            }
        }
        
        func getJarashiName() -> String {
            switch self {
            case UsageProgessStats.DANGEROUS:
                return "jarashi_dangerous"
            case UsageProgessStats.CAUTION:
                return "jarashi_caution"
            case UsageProgessStats.FINE:
                return "jarashi_fine"
            case UsageProgessStats.GOOD:
                return "jarashi_good"
            }
        }
    }

}
