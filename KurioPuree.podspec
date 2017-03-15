Pod::Spec.new do |s|
  s.name             = "KurioPuree"
  s.version          = "2.0.2"
  s.summary          = "A log collector for iOS, modified for Kurio"
  s.homepage         = "https://github.com/hendych/puree-ios"
  s.license          = "MIT"
  s.author           = { "Tomohiro Moro" => "tomohiro-moro@cookpad.com" }
  s.source           = { :git => "https://github.com/hendych/puree-ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'

  s.dependency 'YapDatabase', '~> 2.9.2'
end
