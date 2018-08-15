
Pod::Spec.new do |s|
  s.name         = "RNPaypal"
  s.version      = "1.0.0"
  s.summary      = "RNPaypal"
  s.description  = <<-DESC
                  RNPaypal
                   DESC
  s.homepage     = ""
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/author/RNPaypal.git", :tag => "master" }
  s.source_files  = "RNPaypal/**/*.{h,m}"
  s.requires_arc = true



  s.dependency "React"
  s.dependency "PayPal-iOS-SDK"
  #s.dependency "others"

end

  