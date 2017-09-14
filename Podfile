# Uncomment this line to define a global platform for your project
platform :ios, '8.4'
# Uncomment this line if you're using Swift
use_frameworks!

xcodeproj 'drone-demo-controller.xcodeproj'

source 'https://github.com/CocoaPods/Specs.git'

def source_pods
  pod "Curry", "2.3.3"
  pod "Alamofire", "3.5.0"
  pod "Argo", "3.1.0"
  pod 'CryptoSwift', :git => "https://github.com/krzyzanowskim/CryptoSwift", :branch => "swift2"
end

target 'drone-demo-controller' do
  source_pods
end
