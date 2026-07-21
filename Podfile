# Uncomment the next line to define a global platform for your project
source 'https://cdn.cocoapods.org/'
source 'git@github.com:ibroadlink/BLLibSpecs.git'

platform :ios, '13.0'
use_frameworks!

post_install do |installer|
  # 修复新版 Xcode 移除 libarclite 后，低 deployment target 的 Pod 编译失败
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 13.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end

  # 修复新版 Xcode SDK 中 netinet6/in6.h 私有头文件问题
  Dir.glob('Pods/**/*.{m,mm}').each do |file|
    content = File.read(file)
    if content.include?("#import <netinet6/in6.h>")
      content.gsub!("#import <netinet6/in6.h>\n", '')
      File.chmod(0644, file)
      File.write(file, content)
      puts "✅ 已修复 #{file} 的 netinet6/in6.h 问题"
    end
  end
end


target 'BLAPPSDKDemo' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  # Pods for BLAPPSDKDemo
  pod 'BLLet'

	pod 'Cordova'
	pod 'SSZipArchive'
	pod 'MBProgressHUD'
  pod 'SDWebImage'
  pod 'YYCategories'
  pod 'Masonry'
end
