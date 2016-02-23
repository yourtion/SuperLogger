SuperLogger
===========
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/SuperLogger.svg?style=flat)](http://cocoapods.org/pods/SuperLogger)
[![License](https://img.shields.io/cocoapods/l/SuperLogger.svg?style=flat)](http://cocoapods.org/pods/SuperLogger)
[![Platform](https://img.shields.io/cocoapods/p/SuperLogger.svg?style=flat)](http://cocoapods.org/pods/SuperLogger)
[![Build Status](https://travis-ci.org/yourtion/SuperLogger.svg?branch=master)](https://travis-ci.org/yourtion/SuperLogger)

Save NSLog() to file and send email to developer

## Installation

The preferred way of installation is via CocoaPods. Just add

```ruby
pod 'SuperLogger'
```

and run pod install. It will install the most recent version of SuperLogger.

## How to use

Import the framework header on AppDelegate.m:

```objective-c
#import "SuperLogger.h"
```

Init and set email info:

```objective-c
SuperLogger *logger = [SuperLogger sharedInstance];
// Start NSLogToDocument
[logger redirectNSLogToDocumentFolder];
// Set Email info
logger.mailTitle = @"SuperLoggerDemo Logfile";
logger.mailContect = @"This is the SuperLoggerDemo Logfile";
logger.mailRecipients = @[@"yourtion@gmail.com"];
```

That's it! Have fun with SuperLogger!

Show the Loglist by presentViewController "[[SuperLogger sharedInstance] getListView]" 

```objective-c
[self presentViewController:[[SuperLogger sharedInstance] getListView] animated:YES completion:nil];
```

## ScreenShot

![ScreenShot1](ScreenShot/ScreenShot1.PNG)

![ScreenShot1](ScreenShot/ScreenShot2.PNG)

![ScreenShot1](ScreenShot/ScreenShot3.PNG)
