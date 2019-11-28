#
# Be sure to run `pod lib lint TKA.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TKA'
  s.version          = '0.1.19'
  s.summary          = 'TKA. cbc '

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TKA. cbc doopool
  DESC

  s.homepage         = 'https://github.com/piaomiaoatian667/TKA'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'piaomiaoatian667' => 'piaomiaoatian@yeah.com' }
  s.source           = { :git => 'https://github.com/piaomiaoatian667/TKA.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'TKA/Classes/**/*'
#  s.vendored_framework  = 'TKA/Classes/**.framework'  #Framework目录下的***.framework静态库

  # s.resource_bundles = {
  #   'TKA' => ['TKA/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
#  s.framework  = 'libz'

#   s.frameworks = 'libz.tbd'
#   s.frameworks = 'libxml2.tbd'
#   s.frameworks = 'libsqlite3.0.tbd'
  # s.dependency 'AFNetworking', '~> 2.3'
end
