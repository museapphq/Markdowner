#
# Be sure to run `pod lib lint Markdowner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Markdowner'
  s.version          = '2.0.0'
  s.summary          = 'Live markdown previewer and editor.'
  s.swift_version    = '4.1'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Markdowner is a library intended to edit and preview markdown in real time. It supports custom markdown elements or use only a subset of the standard ones. Custom fonts and colors are also supported.
                       DESC

  s.homepage         = 'https://github.com/rlaguilar/Markdowner'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rlaguilar' => 'rlac1990@gmail.com' }
  s.source           = { :git => 'https://github.com/museapphq/Markdowner.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'Markdowner/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Markdowner' => ['Markdowner/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
