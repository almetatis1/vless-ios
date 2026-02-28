# Podfile for Monti VPN Swift App
# Platform requirement
platform :ios, '17.0'

# Disable CocoaPods stats
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

target 'network' do
  use_frameworks!

  # RevenueCat SDK - same versions as Flutter app
  pod 'RevenueCat', '~> 5.0'
  pod 'RevenueCatUI', '~> 5.0'

  # AppsFlyer SDK for attribution and purchase tracking
  pod 'AppsFlyerFramework', '~> 6.14'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    end
  end
end
