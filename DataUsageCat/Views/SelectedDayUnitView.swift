//
//  SelectedDayUnitView.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2016/06/03.
//  Copyright (c) 2014年 Wataru Suzuki. All rights reserved.
//

import UIKit

class SelectedDayUnitView: UIView {
    @IBOutlet weak var labelDayOfMonth: UILabel!
    @IBOutlet weak var labelUsageTitle: UILabel!
    @IBOutlet weak var labelSavingTitle: UILabel!
    @IBOutlet weak var labelUsageUnit: UILabel!
    @IBOutlet weak var labelSavingUnit: UILabel!
    @IBOutlet weak var buttonUsageValue: UIButton!
    @IBOutlet weak var buttonSavingValue: UIButton!
    /*
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    */
    class func instanceFromNib() -> UIView {
        let xibName = "SelectedDayUnitView"
        let nib = UINib(nibName: xibName, bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
