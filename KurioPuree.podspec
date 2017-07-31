Pod::Spec.new do |s|
  s.name             = "KurioPuree"
  s.version          = "3.0.0"
  s.summary          = "Build on top Swift 3.0, a log collector for iOS, modified for Kurio"
  s.homepage         = "https://github.com/hendych/puree-ios"
  s.license          = "MIT"
  s.author           = { "Tomohiro Moro" => "tomohiro-moro@cookpad.com", "Hendy Christianto" => "hendy@kurio.co.id", "Managam Silalahi" => "managam@kurio.co.id" }
  s.source           = { :git => "https://github.com/hendych/puree-ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'

  s.dependency 'YapDatabase', '~> 2.9.2'
end
