# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'FYI' do
    
	pod 'Firebase/Core'
    pod 'OneSignal'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'Firebase/Storage'
    pod 'AlamofireObjectMapper'
    pod 'RealmSwift'
    pod 'IQKeyboardManagerSwift'
    pod 'KMPlaceholderTextView'
    pod 'FCUUID'
    
  use_frameworks!
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '3.0'
          end
      end
  end
end

target 'OneSignalNotificationServiceExtension' do
    pod 'OneSignal'
end
