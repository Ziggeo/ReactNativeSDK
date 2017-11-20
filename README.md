# ReactNativeSDK

## Demo
For those that like to start off with a demo, you can simply go to [demo repo](https://github.com/Ziggeo/ReactNativeDemo) and follow the steps found in the readme file there.

## Getting started
`$ npm install react-native-ziggeo-library --save`

### Mostly automatic installation
`$ react-native link react-native-ziggeo-library`

### Manual installation
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
	- Update `compileSdkVersion`, `buildToolsVersion`, `targetSdkVersion` and all libs from `com.android.support` package to latest versions.
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

5. Open up `android/app/src/main/java/[...]/MainActivity.java`
  	- Change `extends ReactActivity` to `extends ReactFragmentActivity`
  	- Add `import com.ziggeo.ZiggeoPackage;` to the imports at the top of the file
  	- Add `new ZiggeoPackage()` to the list returned by the `getPackages()` method

## Usage
```javascript
import Ziggeo from 'react-native-ziggeo-library';
```
#### Recoder sample
https://github.com/Ziggeo/ReactNativeDemo/blob/233de22ce4bd12e34c6c2d5bdb2dbaad80e63012/App.js#L18

#### Player player
https://github.com/Ziggeo/ReactNativeDemo/blob/233de22ce4bd12e34c6c2d5bdb2dbaad80e63012/App.js#L21

## Extend functionality
We will presume that you are already familiar and have set up everything needed for the React Native setup on your system. 
If not, we can suggest checking up the following [pages](https://facebook.github.io/react-native/docs/getting-started.html):

There you can select tab `Building Projects with Native Code` and find information about
1. Setting up React Native project for `Windows` / `Mac` / `Linux`
2. Setting up `xCode`
3. Setting up `Android Studio`

Now with everything set up, for Ziggeo to be added you would need to follow this guides:
1. [iOs](https://facebook.github.io/react-native/docs/native-modules-ios.html)
2. [Android](https://facebook.github.io/react-native/docs/native-modules-android.html)
