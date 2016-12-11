Pod::Spec.new do |s|
  s.name             = 'TTGPuzzleVerify'
  s.version          = '1.0.0'
  s.summary          = 'By completing image puzzle game, TTGPuzzleVerify is a more user-friendly verification tool on iOS, which is highly customizable and easy to use.'

  s.description      = <<-DESC
                        By completing image puzzle game, TTGPuzzleVerify is a more user-friendly verification tool on iOS, which is highly customizable and easy to use. It supports square, circle, classic or custom puzzle shape. User can complete the verification by sliding horizontally, vertically or directly dragging the puzzle block.
                        DESC

  s.homepage         = 'https://github.com/zekunyan/TTGPuzzleVerify'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zekunyan' => 'zekunyan@163.com' }
  s.source           = { :git => 'https://github.com/zekunyan/TTGPuzzleVerify.git', :tag => s.version.to_s }
  s.social_media_url = 'http://tutuge.me'

  s.ios.deployment_target = '7.0'
  s.requires_arc     = true

  s.source_files = 'TTGPuzzleVerify/Classes/**/*'
  s.public_header_files = 'TTGPuzzleVerify/Classes/**/*.h'
end
