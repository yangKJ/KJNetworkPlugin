Pod::Spec.new do |s|
  s.name     = "KJNetworkPlugin"
  s.version  = "1.0.0"
  s.summary  = "A Network Plugin With AFNetworking."
  s.homepage = "https://github.com/yangKJ/KJNetworkPlugin"
  s.license  = "MIT"
  s.author   = { "77" => "ykj310@126.com" }
  s.source   = { :git => "https://github.com/yangKJ/KJNetworkPlugin.git", :tag => s.version.to_s}
  s.ios.deployment_target = '9.0'
  s.requires_arc = true
  s.default_subspec = 'Network'

  s.subspec 'Network' do |net|
    net.source_files = "KJNetworkPlugin/Network/*.{h,m}"
    net.dependency 'AFNetworking', "~> 4.0.0"
  end

  s.subspec 'Thief' do |thief|
    thief.source_files = "KJNetworkPlugin/Plugins/Thief/*.{h,m}"
    thief.dependency 'KJNetworkPlugin/Network'
  end

end
