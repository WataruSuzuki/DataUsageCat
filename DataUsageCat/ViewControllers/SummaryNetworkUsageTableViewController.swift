//
//  SummaryNetworkUsageTableViewController.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2015/07/05.
//  Copyright © 2015年 Wataru Suzuki. All rights reserved.
//

/* Hello Swift, Goodbye Obj-C.
 * converted by 'objc2swift' https://github.com/yahoojapan/objc2swift
 * original source: ViewControllers/SummaryNetworkUsageTableViewController.h, ViewControllers/SummaryNetworkUsageTableViewController.m
 */
import UIKit

protocol SummaryNetworkUsageTableViewControllerDelegate: class {
    func summaryNetworkUsageTableViewControllerDidFinish(controller: SummaryNetworkUsageTableViewController, ShowAd isShowAd: Bool)
}

class SummaryNetworkUsageTableViewController: HelpingMonetizeViewController,
    UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var detailTableView: UITableView!

    weak var delegate: SummaryNetworkUsageTableViewControllerDelegate?

    var networkIF: DUCNetworkInterFace?
    var titleStr: String?
    //TODO -> var utilNADView: DJKUtilNendAd?
    //TODO -> var nendBannerView: NADView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.navigationItem.leftBarButtonItem = nil
        }

        let delegate = UIApplication.shared.delegate as! AppDelegate
        if nil == titleStr || titleStr!.isEmpty {
            self.navigationItem.title = NSLocalizedString("detail", comment:"")
            self.setupAdBannerView(delegate: delegate)

        } else {
            self.navigationItem.title = DJKUtilLocale.getFormatedDateStr(by: DateFormatter.Style.full, withDateStr: titleStr)
            self.setupAdBannerView(delegate: delegate)
        }
    }

    func setupAdBannerView(delegate: AppDelegate) {
        if delegate.isUnlockAd {
            //iAd_BannerView.removeFromSuperview()
        } else {
            if UIDevice.current.userInterfaceIdiom == .pad {
                //TODO -> utilNADView = delegate.utilNADView
                //TODO -> nendBannerView = utilNADView?.setupNendBannerView(self.view.frame, uiUserInterfaceIdiom: .phone, sizeType: SIZE_NEND_BANNER_320_50, apiKey: KeyIdAppBankSSP.KEY_BANNER_320_50, spotId: KeyIdAppBankSSP.ID_BANNER_320_50)
                //TODO -> self.view.addSubview(nendBannerView)
            } else {
                addAdMobBannerView(unitId: KeyIdAdMob.BANNER_PHONE)
                //TODO -> DJKViewUtils.setConstraintBottomView(admobBannerView, currentAndTo: self.view)
                //TODO -> DJKViewUtils.setConstraintCenterX(admobBannerView, currentView: self.view)
            }

            //TODO -> admobInterstitial = createAndLoadAdMobInterstitial(KeyIdAdMob.INTERSTITIAL, sender: self)
            //TODO -> admobRewardedVideo = createAndLoadAdMobReward(KeyIdAdMob.REWARDED_VIDEO, sender: self)
        }
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
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return SectionSummary.MAX_DETAIL_DATA.rawValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //var ret: Int = 0
        switch section {
        case SectionSummary.SECTION_RECOMMEND_AD.rawValue:
            let delegate = UIApplication.shared.delegate as! AppDelegate
            if !delegate.isUnlockAd {
                return 1
            }

        case SectionSummary.DETAIL_DATA_WIFI.rawValue:
            return RowDetailWifi.MAX_ROW_DETAIL_DATA_WIFI.rawValue
            
        case SectionSummary.DETAIL_DATA_WWAN.rawValue:
            return RowDetailWwan.MAX_ROW_DETAIL_DATA_WWAN.rawValue
            
        default:
            break
        }

        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        //var ret: NSString = ""
        switch section {
        case SectionSummary.DETAIL_DATA_WIFI.rawValue:
            if UIDevice.current.userInterfaceIdiom == .pad {
                return NSLocalizedString("footer_wifi_pad", comment:"")
            } else {
                return NSLocalizedString("footer_wifi", comment:"")
            }
            
        case SectionSummary.DETAIL_DATA_WWAN.rawValue:
            if UIDevice.current.userInterfaceIdiom == .pad {
                return NSLocalizedString("footer_mobile_data_pad", comment:"")
            } else {
                return NSLocalizedString("footer_mobile_data", comment:"")
            }
            
        default:
            break
        }

        return ""
    }

    func getByteStrFromFloatValue(floatValue: Float) -> String {
        var byteStr = "0.0 MB"
        if nil == titleStr || titleStr == ("") {
            byteStr = String(format: "%1.1f GB", floatValue)
        } else {
            byteStr = String(format: "%1.1f MB", (floatValue * 1000.0))
        }

        return byteStr
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "detailNetworkUsageTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        var usageDataToFloat = Float(0.0)
        switch indexPath.section {
        case SectionSummary.SECTION_RECOMMEND_AD.rawValue:
            cell.textLabel!.text = NSLocalizedString("msg_ad_recommended_title", comment:"(=・ω・=)")
            cell.detailTextLabel!.text = NSLocalizedString("msg_ad_recommended_detail", comment:"おすすめアプリ")
            
        case SectionSummary.DETAIL_DATA_WIFI.rawValue:
            switch indexPath.row {
            case RowDetailWifi.ROW_DETAIL_DATA_WIFI_SEND.rawValue:
                usageDataToFloat = UtilNetworkIF.calcByteData(value: networkIF!.wifiSend, unit: UtilNetworkIF.ByteUnit.GIGA)
                cell.textLabel!.text = NSLocalizedString("data_send", comment:"")
                
            case RowDetailWifi.ROW_DETAIL_DATA_WIFI_RECEIVED.rawValue:
                usageDataToFloat = UtilNetworkIF.calcByteData(value: networkIF!.wifiReceived, unit: UtilNetworkIF.ByteUnit.GIGA)
                cell.textLabel!.text = NSLocalizedString("data_received", comment:"")
                
            default:
                break
            }

            cell.detailTextLabel!.text = self.getByteStrFromFloatValue(floatValue: usageDataToFloat)
            
        case SectionSummary.DETAIL_DATA_WWAN.rawValue:
            switch indexPath.row {
            case RowDetailWwan.ROW_DETAIL_DATA_WWAN_SEND.rawValue:
                usageDataToFloat = UtilNetworkIF.calcByteData(value: networkIF!.wwanSend, unit: UtilNetworkIF.ByteUnit.GIGA)
                cell.textLabel!.text = NSLocalizedString("data_send", comment:"")
                
            case RowDetailWwan.ROW_DETAIL_DATA_WWAN_RECEIVED.rawValue:
                usageDataToFloat = UtilNetworkIF.calcByteData(value: networkIF!.wwanReceived, unit: UtilNetworkIF.ByteUnit.GIGA)
                cell.textLabel!.text = NSLocalizedString("data_received", comment:"")
                
            default:
                break
            }

            cell.detailTextLabel!.text = self.getByteStrFromFloatValue(floatValue: usageDataToFloat)
            
        default:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SectionSummary.DETAIL_DATA_WIFI.rawValue:
            return NSLocalizedString("wifi", comment:"")
            
        case SectionSummary.DETAIL_DATA_WWAN.rawValue:
            return NSLocalizedString("mobile_data", comment:"")
            
        default:
            break
        }

        return ""
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SectionSummary.SECTION_RECOMMEND_AD.rawValue:
            showAdMobInterstitial(unitId: KeyIdAdMob.INTERSTITIAL, rootViewController: self)

        default:
            break
        }
    }

    @IBAction func done() {
        self.delegate!.summaryNetworkUsageTableViewControllerDidFinish(controller: self, ShowAd: false)
    }

    enum SectionSummary: Int {
        case SECTION_RECOMMEND_AD = 0,
        DETAIL_DATA_WIFI,
        DETAIL_DATA_WWAN,
        MAX_DETAIL_DATA
    }
    
    enum RowDetailWifi: Int {
        case ROW_DETAIL_DATA_WIFI_SEND = 0,
        ROW_DETAIL_DATA_WIFI_RECEIVED,
        MAX_ROW_DETAIL_DATA_WIFI
    }
    
    enum RowDetailWwan: Int {
        case ROW_DETAIL_DATA_WWAN_SEND = 0,
        ROW_DETAIL_DATA_WWAN_RECEIVED,
        MAX_ROW_DETAIL_DATA_WWAN
    }
}
