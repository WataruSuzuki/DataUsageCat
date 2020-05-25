platform :ios,'9.0'
# inhibit_all_warnings!
use_frameworks!

target "DataUsageCat" do
  pod 'DJKPurchaseService', :git => 'https://github.com/WataruSuzuki/PurchaseService-iOS.git'
  pod 'NCMB', :git => 'https://github.com/NIFTYCloud-mbaas/ncmb_ios.git'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'GoogleMobileAdsMediationNend'

  target 'DataUsageCatTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do | installer |

  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-DataUsageCat/Pods-DataUsageCat-acknowledgements.plist', 'DataUsageCat/Settings.bundle/Pods-acknowledgements.plist')
end
