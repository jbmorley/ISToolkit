Pod::Spec.new do |s|

  s.name         = "ISForm"
  s.version      = "0.0.1"
  s.summary      = "UI controls for iOS"
  s.homepage     = "https://github.com/jbmorley/ISToolkit"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Jason Barrie Morley" => "jason.morley@inseven.co.uk" }
  s.source       = { :git => "https://github.com/jbmorley/ISToolkit.git", :commit => "238264cbc43c4233e6a140fd6da1aacedcd08dcc" }

  s.source_files = 'Classes/ISFormViewController.{h,m}', 'Classes/ISDisclosureTableViewCell.{h,m}', 'Classes/ISTextViewTableViewCell.{h,m}', 'Classes/ISPickerTableViewCell.{h,m}', 'Classes/ISDetailTableViewCell.{h,m}', 'Classes/ISButtonTableViewCell.{h,m}', 'Classes/ISPickerViewController.{h,m}', 'Classes/ISSettingsViewControllerItem.{h,m}', 'Classes/ISTextFieldTableViewCell.{h,m}', 'Classes/ISImageViewTableViewCell.{h,m}', 'Classes/ISSwitchTableViewCell.{h,m}', 'Classes/ISSegmentedControlTableViewCell.{h,m}', 'Classes/ISTextField.{h,m}'

  s.ios.resource_bundle = { 'ISToolkit' => 'Resources/*.{xib,png}' }

  s.requires_arc = true

  s.platform = :ios, "6.0"

  s.dependency 'ISUtilities', '~> 1.0'

end
