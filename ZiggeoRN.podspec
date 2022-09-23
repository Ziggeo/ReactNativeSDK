Pod::Spec.new do |s|
  s.name             = 'ZiggeoRN'
  s.version          = '1.6.20'
  s.summary          = 'Ziggeo iOS ReactNative SDK'
  s.description      = 'Ziggeo iOS recording and playback SDK'

  s.homepage         = 'http://ziggeo.com'
  s.license          = { :type => 'Confidential', :file => 'LICENSE' }
  s.author           = { 'Ziggeo Inc' => 'support@ziggeo.com' }
  s.source           = { :git => 'https://github.com/Ziggeo/ReactNativeSDK.git' }
  s.source_files     = "ios/**/*.{m,mm,h}"

  s.ios.deployment_target = '11.0'
  s.dependency 'React-Core'
  s.dependency 'ZiggeoMediaSDK'
end
