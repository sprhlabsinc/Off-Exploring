#
#  Be sure to run `pod spec lint SBJson.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "GoogleAnalytics"
  s.version      = "3.13"
  s.summary      = "GoogleAnalytics framework"
  s.source_files  = "Google Analytics/GoogleAnalytics/Library/**/*.{h,m}"
  s.public_header_files = "Google Analytics/GoogleAnalytics/Library/**/*.h"
  s.ios.vendored_library = 'Google Analytics/libGoogleAnalyticsServices.a'
  s.frameworks = 'CoreData', 'SystemConfiguration'
  s.libraries = 'z', 'sqlite3'
end