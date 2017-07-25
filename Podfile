# Uncomment this line to define a global platform for your project
# platform :ios, '10.0'
# Uncomment this line if you're using Swift
use_frameworks!

target ‘Herd’ do

pod 'Firebase'
pod 'Firebase/Auth'
pod 'SwiftLocation'
pod 'XLActionController'
pod 'FontAwesome.swift'
pod 'SwiftDate', '~> 4.0'
pod 'Fakery'
pod 'Spring', :git => 'https://github.com/MengTo/Spring.git', :branch => 'swift3'
pod 'Hero'
pod 'FCAlertView'
pod 'AMScrollingNavbar'
pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'

end

post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
end
