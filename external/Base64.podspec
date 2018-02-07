#
#  Be sure to run `pod spec lint SBJson.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "Base64"
  s.version      = "0.0.1"
  s.summary      = "Base64 framework"
  s.source_files  = "Classes", "Base64/**/*.{h,m}"
  s.public_header_files = "Base64/**/*.h"
end
