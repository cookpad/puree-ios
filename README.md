Puree
========

[![Version](https://img.shields.io/cocoapods/v/Puree.svg?style=flat)](http://cocoadocs.org/docsets/Puree)
[![License](https://img.shields.io/cocoapods/l/Puree.svg?style=flat)](http://cocoadocs.org/docsets/Puree)
[![Platform](https://img.shields.io/cocoapods/p/Puree.svg?style=flat)](http://cocoadocs.org/docsets/Puree)
[![Travis](https://img.shields.io/travis/cookpad/puree-ios.svg?maxAge=2592000)]()

## Description

Puree is a log collector which provides some features like below

- Filtering: Enable to interrupt process before sending log. You can add common params to logs, or the sampling of logs.
- Buffering: Store logs to buffer until log was sent.
- Batching: Enable to send logs by 1 request.
- Retrying: Retry to send logs after backoff time automatically if sending logs fails.

![](./images/overview.png)

Puree helps you unify your logging infrastructure.

## Usage

### Configure Logger

```swift
// Swift

let configuration = PURLoggerConfiguration.default()
configuration.filterSettings = [
    PURFilterSetting(filter: ActivityFilter.self, tagPattern: "activity.**"),
    // filter settings ...
]
configuration.outputSettings = [
    PUROutputSetting(output: ConsoleOutput.self,   tagPattern: "activity.**"),
    PUROutputSetting(output: ConsoleOutput.self,   tagPattern: "pv.**"),
    PUROutputSetting(output: LogServerOutput.self, tagPattern: "pv.**", settings:[PURBufferedOutputSettingsFlushIntervalKey: 10]),
    // output settings ...
]

let logger = PURLogger(configuration: configuration)
```

```objective-c
// Objective-C

PURLoggerConfiguration *configuration = [PURLoggerConfiguration defaultConfiguration];
configuration.filterSettings = @[
    [[PURFilterSetting alloc] initWithFilter:[ActivityFilter class]
                                  tagPattern:@"activity.**"],
    // filter settings ...
];
configuration.outputSettings = @[
    [[PUROutputSetting alloc] initWithOutput:[ConsoleOutput class]
                                  tagPattern:@"activity.**"],
    [[PUROutputSetting alloc] initWithOutput:[ConsoleOutput class]
                                  tagPattern:@"pv.**"],
    [[PUROutputSetting alloc] initWithOutput:[LogServerOutput class]
                                  tagPattern:@"pv.**"
                                  settings:@{PURBufferedOutputSettingsFlushIntervalKey: @10}],
    // output settings ...
];

PURLogger *logger = [[PURLogger alloc] initWithConfiguration:configuration];
```

Expected result

```
tag name                 [ Filter Plugin ]  -> [ Output Plugin ]
-----------------------------------------------------------------
activity.recipe.view  -> [ ActivityFilter ] -> [ ConsoleOutput ]
activity.bargain.view -> [ ActivityFilter ] -> [ ConsoleOutput ]
pv.recipe_detail      -> ( no filter )      -> [ ConsoleOutput ], [ LogServerOutput(FlushInterval:10sec) ]
event.special         -> ( no filter )      -> ( no output )
```

### Post log

Post log object(anyObject) in an arbitrary timing.

```swift
// Swift

logger.post(["recipe_id": "123"], tag: "pv.recipe_detail")
```

```objective-c
// Objective-C

[logger postLog:@{@"recipe_id": @"123"} tag: @"pv.recipe_detail"]
```

### Plugins

You can create plugins. See [Create Plugins](https://github.com/cookpad/puree-ios/wiki/Create-plugins)

## Tag system

### Tag

Tag is consisted of multiple term split by `.`.
For example `activity.recipe.view`, `pv.recipe_detail`.
You can specify tag to log freely.

### Pattern

Filter, Output and BufferedOutput plugins is applied to tag matched logs.
You can specify tag pattern for plugin reaction rules.

#### Simple pattern

Pattern `aaa.bbb` match tag `aaa.bbb`, not match tag `aaa.ccc` (Perfect matching).

#### Wildcard

Pattern `aaa.*` match tags `aaa.bbb`, `aaa.ccc`. Not match tags `aaa`, `aaa.bbb.ccc` (single term).

Pattern `aaa.**` match tags `aaa`, `aaa.bbb` and `aaa.bbb.ccc`. Not match tag `xxx.yyy.zzz` (zero or more terms).

## Installation

Puree is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "Puree"

## Author

Tomohiro Moro, tomohiro-moro@cookpad.com

## License

Puree is available under the MIT license. See the LICENSE file for more info.
