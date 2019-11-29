Pod::Spec.new do |s|

  s.name         = "P9MediaManager"
  s.version      = "1.1.4"
  s.summary      = "Media managing library to handling play and manage resources easily, based on AVFoundation."
  s.homepage     = "https://github.com/P9SOFT/P9MediaManager"
  s.license      = { :type => 'MIT' }
  s.author       = { "Tae Hyun Na" => "taehyun.na@gmail.com" }

  s.ios.deployment_target = '8.0'

  s.source       = { :git => "https://github.com/P9SOFT/P9MediaManager.git", :tag => "1.1.4" }
  s.swift_version = "4.2"
  s.source_files  = "Sources/*.swift"

end
