//
//  CommonUtilChartScrollViewController.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2015/09/24.
//  Copyright © 2015年 Wataru Suzuki. All rights reserved.
//

import UIKit
//import DJKUtilities

extension ChartViewController: UIScrollViewDelegate {
    
    func setupUsageDataForChart() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let preference = UserPreferences.shared
        self.userDefaultLimit = preference.limitUsageValue
        self.csvForThisMonthUsage = delegate.recorder.getUsageResultFromCSV(chartDisp2Month: preference.chartDisp2Month)

        if let usages = self.csvForThisMonthUsage {
            self.totalWeekPageNum = (usages.count / SelectedWeekChartView.PageScroll.MAX_PAGE.rawValue)
            if 0 != (usages.count % SelectedWeekChartView.PageScroll.MAX_PAGE.rawValue) {
                self.totalWeekPageNum += 1
            }
            
            self.currentDayPage = (usages.count - 1)
            self.currentWeekPage = self.totalWeekPageNum - 1
            
            if 0 > self.currentDayPage && UIDevice.current.userInterfaceIdiom == .pad {
                self.weekChartScrollView.isHidden = true
                self.selectedDayScrollView.isHidden = true
                //self.viewNoDataMsg.isHidden = false
                //self.labelNoDataMsg.text = NSLocalizedString("msg_no_data", comment: "")
            }
        }
    }
    
    func setupChartScrollViews() {
        if let usages = self.csvForThisMonthUsage {
            selectedDayUnitViewArrays = self.loadSelectedDayUnitViewArrays(pageNum:usages.count)
            selectedWeekChartViewArrays = self.loadSelectedWeekChartViewArrays(pageNum: self.totalWeekPageNum)
            
            if 0 > self.currentDayPage && UIDevice.current.userInterfaceIdiom == .pad {
                //do nothing
            } else {
                self.initSelectedDayScrollView(numberPages: (usages.count))
                self.initWeekChartScrollView(numberPages: self.totalWeekPageNum)
                self.loadScrollViewWithPage(page: self.currentDayPage, IsCurrentPage: true)
            }
        }
    }
    
    private func loadSelectedDayUnitViewWithPage(page: Int, IsCurrentPage isVisiblePage: Bool) {
        if 0 > page || page >= selectedDayUnitViewArrays!.count {
            return
        }
        
        var frame: CGRect = self.selectedDayScrollView.frame
        frame.origin.x = frame.width * CGFloat(page)
        frame.origin.y = 0
        let unitview = selectedDayUnitViewArrays![page] as! SelectedDayUnitView
        unitview.frame = frame
        
        if let usages = self.csvForThisMonthUsage {
            let dataOfDayArray = usages[page]
            
            let referenceValue = SelectedWeekChartView().getDayReferenceValue(userMax: self.userDefaultLimit)
            let usageValue = PacketUsageConverter.getUsageValue(networkIf: dataOfDayArray)
            unitview.buttonUsageValue!.setTitleColor(SelectedWeekChartView.getUsageChartBarColor(usageValue: usageValue, withMaxReference: referenceValue), for: [])
            let usageValueMegaByte = PacketUsageConverter.get(dataUsage: dataOfDayArray, of: .wwan, unit: .mega)
            let savingValueMegaByte = PacketUsageConverter.get(dataUsage: dataOfDayArray, of: .wifi, unit: .mega)
            unitview.buttonUsageValue!.setTitle(String(format: "%.1f", usageValueMegaByte), for: [])
            unitview.buttonSavingValue!.setTitle(String(format: "%.1f", savingValueMegaByte), for: [])
            unitview.buttonUsageValue!.addTarget(self, action: #selector(ChartViewController.tapSummaryNetworkUsage(sender:)), for: .touchUpInside)
            unitview.buttonSavingValue!.addTarget(self, action: #selector(ChartViewController.tapSummaryNetworkUsage(sender:)), for: .touchUpInside)
            
            let dayOfMonthStr = dataOfDayArray.dateStr
            unitview.labelDayOfMonth!.text = DJKUtilLocale.getFormatedDateStr(by: DateFormatter.Style.full, withDateStr: dayOfMonthStr)
            unitview.labelUsageTitle!.text = NSLocalizedString("wwan", comment:"")
            unitview.labelSavingTitle!.text = NSLocalizedString("wifi", comment:"")
            
            self.selectedDayScrollView.addSubview(unitview)
            
            updateUnitViewHiddenStatus(unitview: unitview, isVisible: !isVisiblePage)
        }
    }
    
    func updateUnitViewHiddenStatus(unitview: SelectedDayUnitView, isVisible: Bool) {
        unitview.labelSavingTitle!.isHidden = isVisible
        unitview.labelUsageTitle!.isHidden = isVisible
        unitview.labelSavingUnit!.isHidden = isVisible
        unitview.labelUsageUnit!.isHidden = isVisible
        unitview.buttonUsageValue!.isHidden = isVisible
        unitview.buttonSavingValue!.isHidden = isVisible
    }
    
    func initWeekChartScrollView(numberPages: Int) {
        if 0 > self.currentDayPage {
            //Do nothing because no usage data.
        } else {
            DJKViewUtils.initScrollView(forPaging: self.weekChartScrollView, withPageNumbers: UInt(numberPages), andTargetDelegate: self)
        }
    }
    
    func initSelectedDayScrollView(numberPages: Int) {
        DJKViewUtils.initScrollView(forPaging: self.selectedDayScrollView, withPageNumbers: UInt(numberPages), andTargetDelegate: self)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.selectedDayScrollView {
            let page = Int(DJKViewUtils.getPageOf(self.selectedDayScrollView))
            self.loadPrevNextDayPage(page: page)
            let focusedPosition = Int(self.currentChartview!.focusViewPosition)
            if page == self.currentDayPage {
                return
            } else if page > self.currentDayPage && (page - self.currentDayPage) >= ((SelectedWeekChartView.PageScroll.MAX_PAGE.rawValue) - focusedPosition) {
                self.currentWeekPage += 1
                self.currentWeekPage += (page - (self.currentDayPage + ((SelectedWeekChartView.PageScroll.MAX_PAGE.rawValue) - focusedPosition))) / (SelectedWeekChartView.PageScroll.MAX_PAGE.rawValue)
                self.gotoSelectedWeekPage(animated: true, withPage: self.currentWeekPage)
            } else if page < self.currentDayPage && 0 < (self.currentDayPage - focusedPosition - page) {
                self.currentWeekPage -= 1
                self.currentWeekPage -= (self.currentDayPage - focusedPosition - page) / (SelectedWeekChartView.PageScroll.MAX_PAGE.rawValue)
                self.gotoSelectedWeekPage(animated: true, withPage: self.currentWeekPage)
            } else {
                //do nothing
            }
            self.loadScrollViewWithPage(page: page, IsCurrentPage: true)
            self.currentDayPage = page
            
        } else if scrollView == self.weekChartScrollView {
            let page = Int(DJKViewUtils.getPageOf(self.weekChartScrollView))
            let focusedPosition = Int(self.currentChartview!.focusViewPosition)
            if page == self.currentWeekPage {
                return
            } else if page > self.currentWeekPage {
                self.currentDayPage = self.currentDayPage + ((SelectedWeekChartView.PageScroll.MAX_PAGE.rawValue) * (page - self.currentWeekPage)) - focusedPosition
            } else if page < self.currentWeekPage {
                self.currentDayPage = self.currentDayPage - ((SelectedWeekChartView.PageScroll.MAX_PAGE.rawValue) * (self.currentWeekPage - page)) - focusedPosition + (SelectedWeekChartView.PageScroll.LAST_DAY.rawValue)
            }
            
            self.gotoSelectedDayPage(animated: true, withPage: self.currentDayPage)
            self.loadPrevNextWeekPage(page: page, withDay: (self.currentDayPage - (SelectedWeekChartView.PageScroll.MAX_PAGE.rawValue)))
            self.loadWeekChartWithPage(weekPage:  page, withDay: self.currentDayPage, IsCurrentPage: true)
            self.currentWeekPage = page
        }
    }
    
    func gotoSelectedDayPage(animated: Bool, withPage page: Int) {
        self.loadPrevNextDayPage(page: page)
        self.loadScrollViewWithPage(page: page, IsCurrentPage: true)
        var bounds: CGRect = self.selectedDayScrollView.bounds
        bounds.origin.x = bounds.width * CGFloat(page)
        bounds.origin.y = 0
        self.selectedDayScrollView.scrollRectToVisible(bounds, animated: animated)
        self.currentDayPage = page
    }
    
    func gotoSelectedWeekPage(animated: Bool, withPage page: Int) {
        self.loadPrevNextWeekPage(page: page, withDay: (self.currentDayPage - (SelectedWeekChartView.PageScroll.MAX_PAGE.rawValue)))
        self.loadWeekChartWithPage(weekPage:  page, withDay: self.currentDayPage, IsCurrentPage: true)
        var bounds: CGRect = self.weekChartScrollView.bounds
        bounds.origin.x = bounds.width * CGFloat(page)
        bounds.origin.y = 0
        self.weekChartScrollView.scrollRectToVisible(bounds, animated: animated)
        self.currentWeekPage = page
    }
    
    func loadPrevNextDayPage(page: Int) {
        self.loadSelectedDayUnitViewWithPage(page: page - 1, IsCurrentPage: false)
        self.loadSelectedDayUnitViewWithPage(page: page + 1, IsCurrentPage: false)
    }
    
    func loadPrevNextWeekPage(page: Int, withDay weekDayNum: Int) {
        self.loadWeekChartWithPage(weekPage:  page - 1, withDay: weekDayNum, IsCurrentPage: false)
        self.loadWeekChartWithPage(weekPage:  page + 1, withDay: weekDayNum, IsCurrentPage: false)
    }
    
    func loadWeekChartWithPage(weekPage: Int, withDay selectedDayPage: Int, IsCurrentPage isVisiblePage: Bool) {
        if weekPage >= self.totalWeekPageNum {
            return
        }
        
        if let usages = self.csvForThisMonthUsage {
            let newChartView = SelectedWeekChartView.createWeekChartPage(
                weekPage: weekPage,
                selectedDayPage: selectedDayPage,
                parentView: self.weekChartScrollView,
                arrayThisMonthUsage:
                usages,
                unitPerPage: SelectedWeekChartView.PageScroll.MAX_PAGE.rawValue,
                userDefaultLimit: self.userDefaultLimit,
                isVisiblePage: isVisiblePage
            )
//            let newChartView = SelectedWeekChartView.createWeekChartPage(weekPage: weekPage, selectedDayPage: selectedDayPage, withParentView: self.weekChartScrollView, arrayThisMonth: usages, unitPerPage: (SelectedWeekChartView.PageScroll.MAX_PAGE.rawValue), userDefaultLimit: self.userDefaultLimit, IsCurrentPage: isVisiblePage)
            if isVisiblePage {
                self.currentChartview = newChartView
                self.setGestureHandlerForFocusView(viewArray: self.currentChartview!.arrayFocusView)
            }
        }
    }
    
    private func loadScrollViewWithPage(page: Int, IsCurrentPage isVisiblePage: Bool) {
        if 0 > page || page >= selectedDayUnitViewArrays!.count {
            return
        }
        
        self.loadWeekChartWithPage(weekPage:  self.currentWeekPage, withDay: page, IsCurrentPage: isVisiblePage)
        self.loadSelectedDayUnitViewWithPage(page: page, IsCurrentPage: isVisiblePage)
    }
    
    func setGestureHandlerForFocusView(viewArray: [AnyObject]) {
        for view: UIView in viewArray as! [UIView] {
            let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChartViewController.handleFocusViewTap(recognizer:)))
            view.addGestureRecognizer(singleTap)
        }
    }
    
    @objc func handleFocusViewTap(recognizer: UITapGestureRecognizer) {
        let focusedPosition = self.currentChartview!.focusViewPosition
        let viewArray: [AnyObject] = self.currentChartview!.arrayFocusView
        for index in 0 ..< viewArray.count {
            let view: UIView = viewArray[index] as! UIView
            if view == recognizer.view {
                let dataIndex = SelectedWeekChartView.getIndexOfTotalData(position: Int(focusedPosition), withNextPosition: (index), withCurrentPage: (self.currentDayPage))
                self.gotoSelectedDayPage(animated: true, withPage: Int(dataIndex))
            }
        }
    }
    
    private func loadSelectedWeekChartViewArrays(pageNum: Int) -> [UIView] {
        var newArrays = [UIView]()
        for _ in 0 ..< pageNum {
            newArrays.append(SelectedWeekChartView.instanceFromNib(currentView: self.view))
        }
        
        return newArrays
    }
    
    private func loadSelectedDayUnitViewArrays(pageNum: Int) -> [UIView] {
        var newArrays = [UIView]()
        for _ in (SelectedWeekChartView.PageScroll.FIRST_DAY.rawValue) ..< pageNum {
            newArrays.append(SelectedDayUnitView.instanceFromNib())
            //newArrays.append(SelectedDayUnitView())
        }
        
        return newArrays
    }
    
    func prepareShowSummaryNetworkUsage(controller: SummaryNetworkUsageTableViewController) {
        if let usages = self.csvForThisMonthUsage {
            let day = usages[self.currentDayPage]
            if nil == networkInterFace {
                networkInterFace = DUCNetworkInterFace()
            }
            controller.networkIF = day
            controller.titleStr = day.dateStr
        }
    }    
}
