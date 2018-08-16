require 'json'
package = JSON.parse(File.read('../package.json'))

Pod::Spec.new do |s|
  s.name         = "RNPaypal"
  s.version      =  package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  RNPaypal
                   DESC
  s.homepage     = "n/a"
  s.license      = package['license']
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "zeddz92" => "lopezredd@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/zeddz92/react-native-paypal.git", :tag => "master" }
  s.source_files  = "RNPaypal/**/*.{h,m}"
  s.requires_arc = true



  s.dependency "React"
  s.dependency "PayPal-iOS-SDK"
  #s.dependency "others"

end

  