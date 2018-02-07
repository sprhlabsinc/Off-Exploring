#
#  Be sure to run `pod spec lint SBJson.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "SBJson"
  s.version      = "3.2.0"
  s.summary      = "SBJson framework”
  s.license      = { :type => "MIT", :file => “README.md” }
  # s.source       = { :git => "https://github.com/stig/json-framework.git", :tag => “3.2.0” }
  s.source_files  = "Classes", “Classes/**/*.{h,m}”
  # s.exclude_files = "Classes/Exclude"
  s.public_header_files = “Classes/**/*.h”
end
