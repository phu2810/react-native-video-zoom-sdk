
Pod::Spec.new do |s|
  s.name         = "VideoZoomSDK"
  s.version      = "1.0.0"
  s.summary      = "VideoZoomSDK"
  s.description  = <<-DESC
                  React Native integration for Video Zoom SDK
                   DESC
  s.homepage     = "https://github.com/phu2810/react-native-video-zoom-sdk"
  s.license      = "MIT"
  s.author             = { "author" => "phunv" }
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/phu2810/react-native-video-zoom-sdk.git" }
  s.source_files  = "ios/*", "ios/src/**/*"

  s.dependency "React"

end

