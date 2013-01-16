# Prototype demo for APS (remote push notifications)

## Documentation 
Apple APS Docs: [here](http://developer.apple.com/library/mac/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/ApplePushService/ApplePushService.html) .

## a few gotchyas:

* APS requires a unique AppId and confiuration for push specifically. You will need to do this for development, and again fro production (2 times!) - This project only address development.
* APS requires an application be unique. This is essentially the bundle identifier , most commonly something like com.companyname.applicationName . 
* make sure your project Bundle Identifier matches the one from your AppID. In this prototype, we have hardcoded the Bundle Identifier to match the AppID `(com.grio.pushproof)`

## Dependencies
For convenience and demonstration, we opted to use a drop in python library: [PyAPN](https://github.com/simonwhitaker/PyAPNs)

Instructions on how to customize messages, etc, can be found at the git repo.

This prototype includes all the necessary files/dependencies to get the provisioning & server side .pem file. In the event these need to be recreated, OR building for production, a quick tutorial covering provisions, etc can be found [here](http://www.raywenderlich.com/3443/apple-push-notification-services-tutorial-part-12)

## Limitations
It is not possible to intercept push notifications discreetly as we have with start/resume/background. Apple limits notification awareness to the AppDelegate and does not allow an NSNotification to relay the event . In the end, this actually favorable since many developers will want to handle these delegate methods in different ways. It does however mean there is an onus on developers implementing the iOS library for APS. There are two steps:

1. notify the PlaynomicsSession of the device token (required)
2. notify the PlaynomicsSession when a notification is read by a user. NOTE: this is the only way to confirm receipt of a notification. 
3. App user must allow for notifications by accepting the alert message created by registerForRemoteNotificationTypes


## DEMO: Working with iOS lib and the python push 
### iOS library

* In the app delegate’s `didFinishLaunchingWithOptions`, add the standard `registerForRemoteNotificationTypes` , noting the type of notification details the application would support. These include badges, alerts, sounds

* implement app delegate method: `didRegisterForRemoteNotificationsWithDeviceToken`. 
if the user accepts the alert to allow APS, this method will pass the deviceToken necessary for the backend server to psuh notifications. We need to pass this using our library using 

```
	[PlaynomicsSession
		enablePushNotificationsWithToken:deviceToken];
```

(For this demo, take note of the token, as it will be needed for testing with the push server)

* implement app delegate method: `didReceiveRemoteNotification`. To confirm receipt we confirm with 

```
	[PlaynomicsSession 							
		pushNotificationsWithPayload:userInfo];	
```
	
* The `pushNotificationsWithPayload` method notifies Playnomics api that the user has received the notification and indeed returned to the app by way of the notification. For this demo, we include a sample notification id # with a timestamp to demonstrate the time passed from push, and to what notifiaction the user has responded.
* place the app in the background
* push a message with the python framework (more on that below)

### Python Push

* open *push.py* in text editor, and replace the `token_hex` varaibale with the token from step 2.b above. * Save the file (For demonstration, we’ve added an example of a custom message. This message, with a push_id key will populate a message in an alert upon user interaction. The push id we will use to pass back to the api. )
* **cd** to the python library

```
\> python push.py
```
 
```
Enter PEM pass phrase: 
```
* use "milo" for the password
* in a second or two, the notification should push.
