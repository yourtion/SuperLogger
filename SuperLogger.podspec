Pod::Spec.new do |s|

  s.name         = "SuperLogger"
  s.version      = "0.6.7"
  s.summary      = "Save NSLog() to file and send email to developer."

  s.description  = <<-DESC
                   Save NSLog() to file and send email to developer.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/yourtion/SuperLogger"
  s.screenshots  = "https://raw.githubusercontent.com/yourtion/SuperLogger/master/ScreenShot/ScreenShot1.PNG", "https://raw.githubusercontent.com/yourtion/SuperLogger/master/ScreenShot/ScreenShot2.PNG", "https://raw.githubusercontent.com/yourtion/SuperLogger/master/ScreenShot/ScreenShot3.PNG"

  s.license      = "Apache License, Version 2.0"
  s.author             = { "Yourtion" => "yourtion@gmail.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/yourtion/SuperLogger.git", :tag => "0.6.7" }
  s.source_files  = "SuperLogger"
  s.resources = ["SuperLogger/Resources/**/*.bundle"]
  s.frameworks  = "Foundation", "UIKit", "MessageUI"
  s.requires_arc = true

end
