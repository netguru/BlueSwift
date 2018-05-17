# xcconfigs - Carthage

This document describes best practices of working with [Carthage](https://github.com/Carthage/Carthage) using [netguru/xcconfigs](https://github.com/netguru/xcconfigs).

---

### Step 1: Include Carthage.xcconfig file

This example assumes that a base `Base.xcconfig` file exists that is imported (explicitly or implicitly) by all other `*.xcconfig` files.

In your `Base.xcconfig`, include `Carthage.xcconfig` file:

```none
// Base.xcconfig

#import "path/to/xcconfigs/Common/Carthge.xcconfig"
```

By importing this file, you now have access to `_CARTHAGE_BUILD_PATH` build setting variable that is automatically used in `FRAMEWORK_SEARCH_PATHS` and that you can use in `carthage copy-frameworks` build phase.

Note that by default [netguru/xcconfigs](https://github.com/netguru/xcconfigs) assumes that `Carthage` directory is in `$(PROJECT_DIR)/Carthage`. If you need to customize that, override `_CARTHAGE_PATH` in your `Base.xcconfig`:

```none
// Base.xcconfig

#include "path/to/xcconfigs/Common/Carthge.xcconfig"
_CARTHAGE_PATH = $(PROJECT_DIR)/Custom/Path/To/Carthage
```

### Step 2: Use \_CARTHAGE_BUILD_PATH in copy-frameworks build phase

When providing framework paths as inputs to your `carthage copy-frameworks` build phase, instead of providing explicit paths, you can take advantage of aforementioned `_CARTHAGE_BUILD_PATH` build setting variable.

As a result, your input file list will look like this, **no matter the platform**:

```none
$(_CARTHAGE_BUILD_PATH)/Result.framework
$(_CARTHAGE_BUILD_PATH)/ReactiveSwift.framework
$(_CARTHAGE_BUILD_PATH)/ReactiveCocoa.framework
```

Instead of like this:

```none
Carthage/Build/iOS/Result.framework
Carthage/Build/iOS/ReactiveSwift.framework
Carthage/Build/iOS/ReactiveCocoa.framework
```

This will allow you to copy-paste the list in case you have a multi-platform project with multiple targets depending on the same frameworks, thus making the whole setup more maintainable and less error-prone.
