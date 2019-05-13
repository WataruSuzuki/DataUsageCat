//
//  DetailThisMonthUsageViewController.swift
//  DataUsageCat
//
//  Created by 鈴木 航 on 2015/07/19.
//  Copyright © 2015年 鈴木 航. All rights reserved.
//

/* Hello Swift, Goodbye Obj-C.
 * converted by 'objc2swift' https://github.com/yahoojapan/objc2swift
 * original source: ViewControllers/DetailThisMonthUsageViewController.h, ViewControllers/DetailThisMonthUsageViewController.m
 */
import UIKit

class DetailThisMonthUsageViewController: CommonUtilChartScrollViewController
{

    var currentViewController: UIViewController!
    @IBOutlet weak var adConstraintView: UIView!

    @IBOutlet weak var anotherContentView: UIView!
    @IBOutlet weak var segmentedControlViewChange: UISegmentedControl!
    @IBOutlet weak var naviToolBar: UIToolbar!
    @IBOutlet weak var barButtonClose: UIBarButtonItem!

    @IBAction func segmentChange(sender: UISegmentedControl) {
        self.changeViewControllerForSegmentIndex(index: sender.selectedSegmentIndex)
    }

    @IBAction func done(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = NSLocalizedString("usage_charts", comment: "")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if nil != admobInterstitial && admobInterstitial!.isReady {
            admobInterstitial!.present(fromRootViewController: self)
        }
        setupChartScrollViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.storyBoardName = delegate.storyBoardName
        setupUsageDataForChart()

        if delegate.isUnlockAd {
        } else {
            addAdMobBannerView(KeyIdAdMob.BANNER_PHONE)
            DJKViewUtils.setConstraintCenterX(admobBannerView, currentView: self.view)
            DJKViewUtils.setConstraintBottomView(admobBannerView, toItem: adConstraintView, currentView: self.view)
            admobInterstitial = createAndLoadAdMobInterstitial(KeyIdAdMob.INTERSTITIAL, sender: self)
        }
        
        segmentedControlViewChange.setTitle(NSLocalizedString("usage_charts", comment: ""), forSegmentAt: ViewControllerIndex.DETAIL_THIS_MONTH.rawValue)
        segmentedControlViewChange.setTitle(NSLocalizedString("breakdown_this_month", comment: ""), forSegmentAt: ViewControllerIndex.SUMMARY_NETWORK.rawValue)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "SummaryNetworkUsageTableViewController":
            let controller = segue.destination as! SummaryNetworkUsageTableViewController
            prepareShowSummaryNetworkUsage(controller: controller)
            break
        default:
            break
        }
    }

    override func tapSummaryNetworkUsage(sender: AnyObject) {
            let sb = self.storyboard!//UIStoryboard(name: self.storyBoardName, bundle: nil)
            let controller = sb.instantiateViewController(withIdentifier: "SummaryNetworkUsageTableViewController") as! SummaryNetworkUsageTableViewController
            prepareShowSummaryNetworkUsage(controller: controller)
            self.navigationController!.pushViewController(controller, animated: true)
    }

    func changeViewControllerForSegmentIndex(index: Int) {
        switch index {
        case ViewControllerIndex.DETAIL_THIS_MONTH.rawValue:
            let detailThisMonthUsage = self.storyboard!.instantiateViewController(withIdentifier: "DetailThisMonthUsageViewController") as! DetailThisMonthUsageViewController
            self.updateContainerAnotherView(vc: detailThisMonthUsage)
            self.navigationItem.title = NSLocalizedString("usage_charts", comment: "")
            
        case ViewControllerIndex.SUMMARY_NETWORK.rawValue:
            let summaryNetworkUsage = self.storyboard!.instantiateViewController(withIdentifier: "SummaryNetworkUsageTableViewController") as! SummaryNetworkUsageTableViewController
            let delegate = UIApplication.shared.delegate as! AppDelegate
            summaryNetworkUsage.networkIF = delegate.cmnuManagedObj.dataUsageCount
            self.updateContainerAnotherView(vc: summaryNetworkUsage)
            self.navigationItem.title = NSLocalizedString("breakdown_this_month", comment: "")
            
        default:
            break
        }
    }

    func updateContainerAnotherView(vc: UIViewController) {
        let isAddNextVC = (vc is SummaryNetworkUsageTableViewController ? true : false)
        if (isAddNextVC/* || self.storyBoardName == "4inch_iPhone"*/) {
            self.addChildViewController(vc)
            if isAddNextVC {
                vc.view.frame = self.anotherContentView.bounds
                self.anotherContentView.addSubview(vc.view)
            } else {
                self.view.addSubview(vc.view)
            }
        }

        self.currentViewController?.view.removeFromSuperview()
        vc.didMove(toParentViewController: self)
        self.currentViewController?.removeFromParentViewController()
        self.currentViewController = vc
    }

    enum ViewControllerIndex: Int {
        case DETAIL_THIS_MONTH = 0,
        SUMMARY_NETWORK,
        MAX_VC_INDEX_NUM
    };
}
