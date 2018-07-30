# xcconfigs - Variables

[netguru/xcconfigs](https://github.com/netguru/xcconfigs) takes advantage of build setting variables to allow more flexible project configuration in comparison to using raw build settings.

This document describes all public variables that you can override in your own `.xcconfig` files.

---

### Environment

#### `_ENVIRONMENTS`

Environments to be used by compiler. As this variable is mapped to compilation conditions, you may use it to write conditionally compiled code.

Assuming you have a follofing `*.xcconfig` file:

```none
// Staging.xcconfig

_ENVIRONMENTS = ENV_STAGING
```

You can use this in both Swift and Objective-C code:

```swift
// Swift

#if ENV_STAGING
    ...
#endif
```

```objc
// Objective-C

#if defined(ENV_STAGING)
   ...
#endif
```

You may have more than one environment set up.

---

### Versioning

#### `_BUILD_VERSION`

Semantic version of the product or the whole project.

#### `_BUILD_NUMBER`

Build number of the product or the whole project.

This build setting is particularly useful on a CI service. For example, assuming you use [Travis CI](https://travis-ci.com), you can directly set `_BUILD_NUMBER=$TRAVIS_BUILD_NUMBER` build setting when invoking `xcodebuild`.

---

### Bundle

#### `_BUNDLE_NAME`

Name of the product bundle.

This is different from Target Name, in that it is used as a name of the executable. This means it has more restrictions when it comes to allowed characters – for example, Framework targets might be called `MyFramework (iOS)`, but, as `_BUNDLE_NAME` doesn't allow spaces, it has to be changed to just `MyFramework` or `MyFramework_iOS`.

#### `_BUNDLE_IDENTIFIER`

Identifier of the product bundle.

This variable is used as `CFBundleIdentifier` in `Info.plist`.

#### `_BUNDLE_INFOPLIST_PATH`

Path to `Info.plist` file of the product bundle.

#### `_BUNDLE_TESTABLE`

Whether the product bundle is `@testable`.

---

### Deployment

#### `_DEPLOYMENT_TARGET_IOS`

Minimum deployment target of the product on iOS.

#### `_DEPLOYMENT_DEVICES_IOS`

Targeted device families on iOS. `1` means iPhone and `2` means iPad.

#### `_DEPLOYMENT_TARGET_MACOS`

Minimum deployment target of the product on macOS.

#### `_DEPLOYMENT_TARGET_TVOS`

Minimum deployment target of the product on tvOS.

#### `_DEPLOYMENT_DEVICES_TVOS`

Targeted device families on tvOS. `3` means Apple TV and is the only valid value.

#### `_DEPLOYMENT_TARGET_WATCHOS`

Minimum deployment target of the product on watchOS.

#### `_DEPLOYMENT_DEVICES_WATCHOS`

Targeted device families on watchOS. `4` means Apple Watch and is the only valid value.

---

### Code signing

#### `_CODESIGN_STYLE`

Code signing style. Can be either `Automatic` or `Manual`, case-sensitive.

#### `_CODESIGN_DEVELOPMENT_TEAM`

Development team used along with `_CODESIGN_IDENTITY` and `_CODESIGN_PROFILE_SPECIFIER` to manually code sign the product.

#### `_CODESIGN_IDENTITY`

Identity used along with `_CODESIGN_DEVELOPMENT_TEAM` and `_CODESIGN_PROFILE_SPECIFIER` to manually code sign the product.

#### `_CODESIGN_PROFILE_SPECIFIER`

Provisioning profile specifier used along with `_CODESIGN_DEVELOPMENT_TEAM` and `_CODESIGN_IDENTITY` to manually code sign the product.

#### `_CODESIGN_ENTITLEMENTS_PATH`

Path to `*.entitlements` file containing sandboxed capabilities of the product.

---

### Assets

#### `_ASSET_ICON`

Name of an asset that will be used as product application's icon.

#### `_ASSET_LAUNCHIMAGE`

Name of an asset that will be used as product application's launch image.

---

### Compiler

#### `_COMPILER_HARD_MODE`

Whether to enable hard mode in Objective-C and Swift compilers. :trollface:

Hard mode enables "Treat warnings as errors" for both Objective-C and Swift. It should be on by default, however, you could opt-out of it in case you're dealing with a legacy project with lots of low-severity warnings.

#### `_COMPILER_SWIFT_VERSION`

Swift language version used by the product.

#### `_COMPILER_SWIFT_FLAGS`

Additional flags passed to Swift compiler.

Of of the most useful flags you can take advantage in debug configurations is `-Xfrontend -debug-time-function-bodies` which will print how much time Swift compiler spent on compiling particular function (or computed property). This is very, very useful for debugging long compile times.

#### `_COMPILER_SWIFT_BRIDGING_HEADER_PATH`

Path to Objective-C → Swift bridging header.

#### `_COMPILER_FRAMEWORK_SEARCH_PATHS`

Framework search paths of Objective-C and Swift compilers.

#### `_COMPILER_OBJC_HEADER_SEARCH_PATHS`

Header search paths of Objective-C compiler.

#### `_COMPILER_OBJC_LINKER_FLAGS`

Additional flags passed to Objective-C linker.

You may use this variable to link your target to libraries, such as `-lxml2`.
