Pod::Spec.new do |s|
  s.name     = "KJNetworkPlugin"
  s.version  = "1.0.12"
  s.summary  = "A Network Plugin With AFNetworking."
  s.homepage = "https://github.com/yangKJ/KJNetworkPlugin"
  s.license  = "MIT"
  s.author   = { "77" => "ykj310@126.com" }
  s.source   = { :git => "https://github.com/yangKJ/KJNetworkPlugin.git", :tag => s.version.to_s}
  s.ios.deployment_target = '9.0'
  s.requires_arc = true

  s.subspec 'Network' do |xx|
    xx.source_files = "KJNetworkPlugin/Network/*.{h,m}"
    xx.dependency 'AFNetworking', "~> 4.0.0"
  end
  
  s.subspec 'Manager' do |xx|
    xx.source_files = "KJNetworkPlugin/Manager/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Network'
  end
  
  s.subspec 'Batch' do |xx|
    xx.source_files = "KJNetworkPlugin/Batch/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Network'
  end
  
  s.subspec 'Chain' do |xx|
    xx.source_files = "KJNetworkPlugin/Chain/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Network'
  end
  
  ################## 插件板块 ##################
  
  s.subspec 'Base' do |xx|
    xx.source_files = "KJNetworkPlugin/Plugins/Base/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Network'
  end

  s.subspec 'Thief' do |xx|
    xx.source_files = "KJNetworkPlugin/Plugins/Thief/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
  end
  
  s.subspec 'Certificate' do |xx|
    xx.source_files = "KJNetworkPlugin/Plugins/Certificate/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
  end

  s.subspec 'Cache' do |xx|
    xx.source_files = "KJNetworkPlugin/Plugins/Cache/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
    xx.dependency 'YYCache', "~> 1.0.4"
  end
  
  s.subspec 'Anslysis' do |xx|
    xx.source_files = "KJNetworkPlugin/Plugins/Anslysis/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
    xx.dependency 'MJExtension', "~> 3.3.0"
  end
  
  s.subspec 'Loading' do |xx|
    xx.source_files = "KJNetworkPlugin/Plugins/Loading/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
    xx.dependency 'MBProgressHUD', "~> 1.2.0"
  end
  
  s.subspec 'Capture' do |xx|
    xx.source_files = "KJNetworkPlugin/Plugins/Capture/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
    xx.dependency 'MJExtension', "~> 3.3.0"
  end

  s.subspec 'Code' do |xx|
    xx.source_files = "KJNetworkPlugin/Plugins/Code/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
  end

  s.subspec 'Refresh' do |xx|
    xx.source_files = "KJNetworkPlugin/Plugins/Refresh/*.{h,m}"
    xx.dependency 'KJNetworkPlugin/Base'
  end
  
end
