# Uncomment this line to define a global platform for your project

platform :ios, '8.0'

target 'DailyDapp' do

pod 'Fabric'
pod 'Crashlytics'
pod 'TwitterCore'
pod 'TwitterKit'
pod 'MBProgressHUD'

end

post_install do |installer|
  installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
    configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  end
end
