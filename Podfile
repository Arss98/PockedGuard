# Podfile
platform :ios, '15.0'
use_frameworks!

# Исправление проблем с путями Metal
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Удаляем проблемные пути
      config.build_settings['LIBRARY_SEARCH_PATHS'] = [
        "$(inherited)",
        "$(SDKROOT)/usr/lib/swift"
      ]
      
      config.build_settings['SWIFT_USE_MODULE_LINKING'] = 'NO'
      config.build_settings['SWIFT_USE_LIBRARY_EVOLUTION'] = 'YES'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
  
  system("rm -rf ~/Library/Developer/Xcode/DerivedData/*")
end

target 'PockedGuard' do
  pod 'SwiftGen', '~> 6.6.2'
  pod 'RxSwift', '6.9.0'
  pod 'RxCocoa', '6.9.0'
end