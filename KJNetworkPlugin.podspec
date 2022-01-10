#
# Be sure to run `pod lib lint KJNetworkPlugin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name     = "KJNetworkPlugin"
  s.version  = "1.0.14"
  s.summary  = "A Network Plugin With AFNetworking."
  s.homepage = "https://github.com/yangKJ/KJNetworkPlugin"
  s.license  = "MIT"
  s.author   = { "77" => "ykj310@126.com" }
  s.source   = { :git => "https://github.com/yangKJ/KJNetworkPlugin.git", :tag => s.version.to_s}
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.requires_arc = true
  s.static_framework = true

  s.subspec 'Network' do |xx|
    xx.source_files = "NetworkPlugin/Network/*.{h,m}"
    xx.dependency 'AFNetworking', "~> 4.0.0"
  end
  
  s.subspec 'Manager' do |xx|
    xx.source_files = "NetworkPlugin/Manager/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Network'
  end
  
  s.subspec 'Batch' do |xx|
    xx.source_files = "NetworkPlugin/Batch/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Network'
  end
  
  s.subspec 'Chain' do |xx|
    xx.source_files = "NetworkPlugin/Chain/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Network'
  end
  
  ################## 插件板块 ##################
  
  s.subspec 'Base' do |xx|
    xx.source_files = "NetworkPlugin/Plugins/Base/*.{h,m}"
    xx.prefix_header_contents = '#import "KJNetworkPlugin-Bridging-Header.h"'
    xx.dependency 'KJNetworkPlugin/Network'
  end

  s.subspec 'Thief' do |xx|
    xx.source_files = "NetworkPlugin/Plugins/Thief/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
  end
  
  s.subspec 'Certificate' do |xx|
    xx.source_files = "NetworkPlugin/Plugins/Certificate/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
  end

  s.subspec 'Cache' do |xx|
    xx.source_files = "NetworkPlugin/Plugins/Cache/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
    xx.dependency 'YYCache', "~> 1.0.4"
  end
  
  s.subspec 'Anslysis' do |xx|
    xx.source_files = "NetworkPlugin/Plugins/Anslysis/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
    xx.dependency 'MJExtension', "~> 3.3.0"
  end
  
  s.subspec 'Loading' do |xx|
    xx.source_files = "NetworkPlugin/Plugins/Loading/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
    xx.dependency 'MBProgressHUD', "~> 1.2.0"
  end
  
  s.subspec 'Capture' do |xx|
    xx.source_files = "NetworkPlugin/Plugins/Capture/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
    xx.dependency 'MJExtension', "~> 3.3.0"
  end

  s.subspec 'Code' do |xx|
    xx.source_files = "NetworkPlugin/Plugins/Code/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
  end

  s.subspec 'Refresh' do |xx|
    xx.source_files = "NetworkPlugin/Plugins/Refresh/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
  end
  
  s.subspec 'Indicator' do |xx|
    xx.source_files = "NetworkPlugin/Plugins/Indicator/*.swift"
    xx.dependency 'KJNetworkPlugin/Base'
  end
  
end
