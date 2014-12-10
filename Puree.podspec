Pod::Spec.new do |s|
  s.name             = "Puree"
  s.version          = "1.0.0"
  s.summary          = "A log collector for iOS."
  s.homepage         = "https://github.com/cookpad/puree-ios"
  s.license          = "MIT"
  s.author           = { "Tomohiro Moro" => "tomohiro-moro@cookpad.com" }
  s.source           = { :git => "https://github.com/cookpad/puree-ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'Puree' => ['Pod/Assets/*.png']
  }

  s.dependency 'YapDatabase', '~> 2.5.4'
end
