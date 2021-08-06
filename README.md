# ReactNativeSDK

## Demo
For those that like to start off with a demo, you can simply go to [demo repo](https://github.com/Ziggeo/ReactNativeDemo) and follow the steps found in the readme file there.

### Automatic Installation
```
$ npm install react-native-ziggeo-library --save
$ react-native link
```

iOS project will require additional steps mentioned at the Manual Installation section below   
Android project also requires to follow point 2 and point 3(the first part) mentioned at the Manual Installation section below

### Manual Installation
#### Android
1. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-ziggeo-library'
  	project(':react-native-ziggeo-library').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-ziggeo-library/android')
  	```

2. Open up `android/build.gradle`
	- Insert the following line inside the `allprojects/repositories` block:
	```
	maven { url 'https://jitpack.io' }
	```
  	
3. Open up `android/app/build.gradle`  
	- Set `compileSdkVersion` and `targetSdkVersion` = `28`, `minSdkVersion` >= `16`, `buildToolsVersion` = `28.0.3`,  all libs from `com.android.support` package to `28.0.0`.  
	- Insert the following line inside the `dependencies` block:  
	```
	compile project(':react-native-ziggeo-library')
	```

4. Open up `android/app/AndroidManifest.xml` 
	- Insert the following line inside the `manifest` block:
	```
	xmlns:tools="http://schemas.android.com/tools"
	```
	- Insert the following line inside the `application` block:
	```
	tools:replace="android:name"
	```

5. Open up `android/app/src/main/java/[...]/MainApplication.java`
  	- Add `import com.ziggeo.ZiggeoPackage;` to the imports at the top of the file below `package`
  	- Add `new ZiggeoPackage()` to the list returned by the `getPackages()` method

#### iOS installation using pods
add these lines to your Podfile and run 'pod install'
```
  pod 'iOS-Client-SDK', :git => 'https://github.com/Ziggeo/iOS-Client-SDK.git'
```

#### iOS manual installation
1. `$ npm install react-native-ziggeo-library --save`
2. `$ react-native link`
3. download `Ziggeo.framework` from `Ziggeo-Client-SDK` repository: https://github.com/Ziggeo/iOS-Client-SDK/tree/master/Ziggeo/Output/

There are two framework versions: release and universal. Use universal framework for development and debugging purposes and switch to Release framework to build the application for App Store

4. open the iOS project in XCode and add the Ziggeo.framework into embedded and linked frameworks at the project settings

Sometimes iOS project compilation may raise analyzer issues. Use these commands to clean and build the project from scratch:
```
$ cd ios
$ rm -rf build
$ xcodebuild clean
```

#### iOS React Native app additional required steps
Edit AppDelegate.m to change application audio session settings:

at the beginning of the file:
```
@import AVFoundation;
```

at the beginning of `application didFinishLaunchingWithOptions` method:
```
[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                 withOptions:AVAudioSessionCategoryOptionDuckOthers 
				 | AVAudioSessionCategoryOptionDefaultToSpeaker
                                 error:nil];
```

## Usage
```javascript
import Ziggeo from 'react-native-ziggeo-library';
```
#### Recoder Sample
https://github.com/Ziggeo/ReactNativeDemo/blob/233de22ce4bd12e34c6c2d5bdb2dbaad80e63012/App.js#L18

#### Player Sample
https://github.com/Ziggeo/ReactNativeDemo/blob/233de22ce4bd12e34c6c2d5bdb2dbaad80e63012/App.js#L21

## Extend Functionality
Need to brush up on React Native? See [here](https://facebook.github.io/react-native/docs/getting-started.html):

Select tab `Building Projects with Native Code` to find:
1. Setting up React Native project for `Windows` / `Mac` / `Linux`
2. Setting up `xCode`
3. Setting up `Android Studio`

For more information on how to use natives modules via React Native, see here:
1. [iOs](https://facebook.github.io/react-native/docs/native-modules-ios.html)
2. [Android](https://facebook.github.io/react-native/docs/native-modules-android.html)
