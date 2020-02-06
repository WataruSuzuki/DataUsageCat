//
//  MeterViewController.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2015/07/04.
//  Copyright © 2015年 Wataru Suzuki. All rights reserved.
//

import UIKit
import CoreData
import BubbleTransition
import RMPZoomTransitionAnimator
import DJKPurchaseService

class MeterViewController: HelpingMonetizeViewController,
    AboutThisAppViewControllerDelegate,
    SettingsViewControllerDelegate,
    NotifyUsageStatusViewControllerDelegate,
    SummaryNetworkUsageTableViewControllerDelegate,
    //ADGManagerViewControllerDelegate, ADGInterstitialDelegate,
    //UIViewControllerTransitioningDelegate,
    UIPopoverControllerDelegate
{
    let bubbleTransition = BubbleTransition()
    let zoomTransitionAnimator = RMPZoomTransitionAnimator()
    
    var isPrepareShowDayUsage: Bool = false
    
    private let privacyPolicyUrl = "https://github.com/WataruSuzuki/DataUsageCat/blob/master/PRIVACY_POLICY.md"
    
    @IBOutlet weak var meterView: MeterView!

    override func viewDidLoad() {
        //setupPersonalizedAdConsent()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(MeterViewController.meterViewWillAppear), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.meterView.setInitViewImage()
        setUpTapActions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.meterViewWillAppear()
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
                Thread.detachNewThreadSelector(#selector(MeterViewController.checkNotificationAuthorization), toTarget:self, with: nil)
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
    
    @objc func meterViewWillAppear() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let preference = UserPreferences.shared
        self.meterView.userDefaultLimit = preference.limitUsageValue
        
        delegate.recorder.fetchMonthNetworkUsage(context: delegate.packetStore.context)
        meterView.dataUsageCount = delegate.recorder.dataUsageCount
        if #available(iOS 10.0, *) {
            UtilLocalNotification().catRestartDataMonitoring()
        }
        
        setupAdMob()
        
        self.meterView.setViewTitle()
        self.meterView.setNeedlePosition()
        self.checkPermissions()
    }
    
    private func setupAdMob() {
        PurchaseService.shared.confirmPersonalizedConsent(publisherIds: [KeyIdAdMob.PUBLISHER_ID], privacyPolicyUrl: privacyPolicyUrl) { (success) in
            if success {
                //TODO -> GADMobileAds.sharedInstance().start(completionHandler: nil)

                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.updateViewUsageResult(size: self.view.frame.size, orientation: UIApplication.shared.statusBarOrientation)
                    self.updateAllAdBannerView()
                    self.loadAdMobInterstitial(unitId: KeyIdAdMob.INTERSTITIAL)
                } else {
                    self.navigationController?.isNavigationBarHidden = true
                    self.updateAllAdBannerView()
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.meterView.setInitViewImage()
    }
    
    private func updateViewUsageResult(size: CGSize, orientation: UIInterfaceOrientation) {
        let collection = UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.regular)
        if traitCollection.containsTraits(in: collection) {
            // Regular size
        } else {
            // Compact size
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.updateViewUsageResult(size: size, orientation: UIApplication.shared.statusBarOrientation)
            
        })
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
    
    private func showInterstitialAdDependingOnTheConditions(isForce: Bool) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let isShowTime = (isForce || 0 == (delegate.countAdMobInterstitial % 10))
        
        if isShowTime {
            showAdMobInterstitial(rootViewController: self)
        }

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
                    Thread.detachNewThreadSelector(#selector(MeterViewController.delayShowAd), toTarget:self, with: nil)
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
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return startTransition(forPresented: presented, presenting: presenting, source: source)
//    }
//
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return dismissTransition(forDismissed: dismissed)
//    }
//
//    func startTransition(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        let navigationController = presented as! UINavigationController
//        if let destination = navigationController.viewControllers.last {
//                bubbleTransition.transitionMode = .present
//            bubbleTransition.startingPoint = getStartPoint(destination: destination)
//                bubbleTransition.bubbleColor = UIColor.white//getDucGreenColor()
//                return bubbleTransition
//        }
//        return nil
//    }
//
//    func dismissTransition(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        let navigationController = dismissed as! UINavigationController
//        if let destination = navigationController.viewControllers.last {
//                bubbleTransition.transitionMode = .dismiss
//            bubbleTransition.startingPoint = getStartPoint(destination: destination)
//                bubbleTransition.bubbleColor = UIColor.white//getDucGreenColor()
//                return bubbleTransition
//
//        }
//        return nil
//    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
//        case "ChartViewController":
//            navigationController.transitioningDelegate = self
//            navigationController.modalPresentationStyle = .custom

        case "NotifyUsageStatusViewController":
            guard let navigation = segue.destination as? UINavigationController else { return }
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popPresent = navigation.popoverPresentationController {
                    popPresent.sourceView = meterView.buttonTopCatStatusImage.superview
                    popPresent.sourceRect = meterView.buttonTopCatStatusImage.frame
                }
            }

            let controller = navigation.viewControllers.last as! NotifyUsageStatusViewController
            controller.statusImageFilename = meterView.statusImageFilename
            controller.delegate = self
            
        case "SettingsViewController":
            guard let navigation = segue.destination as? UINavigationController else { return }
            let controller = navigation.viewControllers.last as! SettingsViewController
            controller.delegate = self
            
        case "AboutThisAppViewController":
            let controller = (segue.destination as! UINavigationController).viewControllers.last as! AboutThisAppViewController
            controller.delegate = self
            
        default:
            break
        }
    }
    
    func updateAllAdBannerView() {
        self.updateAdMobBannerView()
    }
    
    func updateAdMobBannerView() {
        addAdMobBannerView(unitId: UIDevice.current.userInterfaceIdiom == .pad ? KeyIdAdMob.BANNER_PAD : KeyIdAdMob.BANNER_PHONE, edge: .top)
    }

    func getDucGreenCgColor() -> CGColor {
        return getDucGreenColor().cgColor
    }
    
    func getDucGreenColor() -> UIColor {
        return UIColor(red: 0, green: 0.392, blue: 0, alpha: 1.0)
    }
    
    private func setUpTapActions() {
        self.meterView.tapTopCatStatus = {
            self.performSegue(withIdentifier: "NotifyUsageStatusViewController", sender: self)
        }
        self.meterView.tapCurrentMonth = {
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.performSegue(withIdentifier: "ChartViewController", sender: self)
            } else {
                self.performSegue(withIdentifier: "NotifyUsageStatusViewController", sender: self)
            }
        }
        self.meterView.tapInfo = {
            self.performSegue(withIdentifier: "AboutThisAppViewController", sender: self)
        }
        self.meterView.tapJarashi = {
            self.performSegue(withIdentifier: "SettingsViewController", sender: self)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
