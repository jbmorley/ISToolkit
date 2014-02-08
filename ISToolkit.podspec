Pod::Spec.new do |s|

  s.name         = "ISToolkit"
  s.version      = "0.0.1"
  s.summary      = "UI controls for iOS"
  s.homepage     = "https://github.com/jbmorley/ISToolkit"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Jason Barrie Morley" => "jason.morley@inseven.co.uk" }
  s.source       = { :git => "https://github.com/jbmorley/ISToolkit.git", :commit => "1b8f0d8c643203f2a33bbedde8466793a24a074c" }

  s.source_files = 'Classes/*.{h,m}'

  s.requires_arc = true

  s.platform = :ios, "6.0"

end
