
# react-native-paypal
A wrapper for the paypal sdk for both android and ios.

## Getting started

`$ npm install react-native-paypal-lib --save`

### Mostly automatic installation

`$ react-native link react-native-paypal-lib`

#### iOS Configuration

Configure the project:
```
cd ios && pod init
```

Add the next line to your **PodFile**:
```diff
+ pod 'RNPaypal', :path => '../node_modules/react-native-paypal-lib/ios'
```

Install the RNPaypal pod:
```
pod install
```


### Manual installation

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-paypal-lib` and add `RNPaypal.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNPaypal.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNPaypalPackage;` to the imports at the top of the file
  - Add `new RNPaypalPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-paypal-lib'
  	project(':react-native-paypal-lib').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-paypal/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-paypal-lib')
  	```


## Properties
| Prop | Description | Type |
|---|---|---|
|**`clientId`**|Your client id for each relevant environment, as obtained from developer.paypal.com |*String*|
|**`environment`**|Your paypal environment. |*RNPaypal.ENVIRONMENT*|
|**`intent`**|Name of the animation, see below for available animations. |*RNPaypal.INTENT*|
|**`price`**| Amount in the given currency to process. Must be positive. |*Integer*|
|**`currency`**|ISO standard currency code (http://en.wikipedia.org/wiki/ISO_4217). |*String*|
|**`description`**|A short description of the transaction, for display to the user. |*String*|
|**`locale`**|ISO standard locale code (http://en.wikipedia.org/wiki/ISO_4217) |*String*|
|**`acceptCreditCards`**|If set to NO, the SDK will only support paying with PayPal, not with credit cards. |*Bool*|


## Environments
The Environment. The allowed values are:
- **`NO_NETWORK`**. No need for real credentials at Login prompt.
- **`SANDBOX`**.  You'll need sandbox credentials in order to work at (https://developer.paypal.com/developer/accounts).
- **`PRODUCTION`**. In order to work you need to have an production client id.


## Intents
The intent. The allowed values are:
- **`SALE`**. For immediate payment.
- **`AUTHORIZE`**.  For a delayed payment.
- **`ORDER`**. An Order.

## Usage
```javascript
import RNPaypal from 'react-native-paypal-lib';

RNPaypal.paymentRequest({
    clientId: '<YOUR CLIENT ID>',
    environment: RNPaypal.ENVIRONMENT.NO_NETWORK,
    intent: RNPaypal.INTENT.SALE,
    price: 60,
    currency: 'USD',
    description: `Android testing`,
    locale: 'en',
    acceptCreditCards: true
}).then(response => {
    console.log(response)
}).catch(err => {
    console.log(err.message)
})
```
  