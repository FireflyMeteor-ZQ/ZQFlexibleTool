Pod::Spec.new do |spec|
  spec.name         = 'ZQFlexibleTool'
  spec.version      = '1.0.0'
  spec.summary      = 'A flexible iOS utility toolkit with custom navigation, tab bar, file, permission, and base controller modules.'
  spec.homepage     = 'https://github.com/FireflyMeteor-ZQ/ZQFlexibleTool'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'JessonZhang' => 'zjsaufe@qq.com' }
  spec.source       = { :git => 'https://github.com/FireflyMeteor-ZQ/ZQFlexibleTool.git', :tag => spec.version.to_s }
  spec.platform     = :ios, '13.0'
  spec.swift_version = '5.0'
  spec.source_files = 'ZQFlexibleTool/Sources/ZQFlexibleTool/**/*.swift'
  spec.frameworks   = ['UIKit', 'Foundation']
  spec.dependency   'TangramKit', '1.4.2'
end
