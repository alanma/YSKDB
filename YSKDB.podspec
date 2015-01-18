#
# Be sure to run `pod lib lint YSKDB.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "YSKDB"
  s.version          = "0.0.2"
  s.summary          = "Parse based wrapper for FMDB"
  s.description      = "YSKDB provides a simple way to use SQLite inspired by Parse"
  s.homepage         = "https://github.com/kitasuke/YSKDB"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "kitasuke" => "yusuke2759@gmail.com" }
  s.source           = { :git => "https://github.com/kitasuke/YSKDB.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'YSKDB' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency "FMDB/SQLCipher"
end
