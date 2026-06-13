Pod::Spec.new do |s|
  s.name             = 'TTGPuzzleVerify'
  s.version          = '2.0.0'
  s.summary          = 'A native iOS puzzle verification component with image backgrounds, custom shapes, metrics, and SwiftUI/UIKit/Objective-C integration.'

  s.description      = <<-DESC
                        TTGPuzzleVerify is a customizable native iOS puzzle verification component. It supports image or gradient backgrounds, classic/square/circle/custom puzzle paths, horizontal/vertical/free dragging, manual or automatic verification, retry and lock states, behavior metrics, and integration from SwiftUI, UIKit, and Objective-C.
                        DESC

  s.homepage         = 'https://github.com/zekunyan/TTGPuzzleVerify'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zekunyan' => 'zekunyan@163.com' }
  s.source           = { :git => 'https://github.com/zekunyan/TTGPuzzleVerify.git', :tag => s.version.to_s }
  s.social_media_url = 'http://tutuge.me'

  s.platform         = :ios, '16.0'
  s.swift_version    = '5.9'
  s.requires_arc     = true

  s.source_files = 'TTGPuzzleVerify/Classes/**/*.swift'
end
