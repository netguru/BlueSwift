# xcconfigs - CocoaPods

This document describes best practices of working with [CocoaPods](https://cocoapods.org) using [netguru/xcconfigs](https://github.com/netguru/xcconfigs).

---

### Step 1: Provide proper configuration for CocoaPods

For this example, let's assume you want to create an iOS app target with unit tests and have three build configurations in your project – `Development`, `Staging` and `Release`.

To be sure that CocoaPods takes this into consideration (and doesn't assume you use default `Debug` and `Release` ones), provide information about them in your `Podfile`:

```none
project 'MyProject',
  'Development' => :debug,
  'Staging' => :release,
  'Release' => :release

target 'Application' do
  ...
end

target 'Tests' do
  ...
end
```

Based on that, CocoaPods will generate the following `*.xcconfig` hierarchy:

```none
Pods/Target Support Files
 │
 ├ Pods-Application
 │  ├ Pods-Application.development.xcconfig
 │  ├ Pods-Application.staging.xcconfig
 │  ├ Pods-Application.release.xcconfig
 │  └ ...
 │
 ├ Pods-Tests
 │  ├ Pods-Tests.development.xcconfig
 │  ├ Pods-Tests.staging.xcconfig
 │  ├ Pods-Tests.release.xcconfig
 │  └ ...    
 │
 └ ...
```

Yes, all of those should be included in appropriate places in your `*.xcconfig` files...

### Step 2: Recreate your own \*.xcconfig files

As `#include` statements cannot be conditional in `*.xcconfig` files and as CocoaPods will complain if you ignore to include them, you have to other option than to recreate the above configuration:

```none
Development - Development.xcconfig
 ├ Application - Application-Development.xcconfig
 └ Tests - Tests-Development.xcconfig

Staging - Staging.xcconfig
 ├ Application - Application-Staging.xcconfig
 └ Tests - Tests-Staging.xcconfig

Release - Release.xcconfig
 ├ Application - Application-Release.xcconfig
 └ Tests - Tests-Release.xcconfig
```

It's good to create additional `Common.xcconfig`, `Application-Common.xcconfig` and `Tests-Common.xcconfig` files so that settings can be shared between all the versions. The next step assumes you did that.

### Step 3: Include CocoaPods's \*.xcconfig files in your ones

Now, add proper `#include`s in your `*.xcconfig` files:

```none
// Application-Common.xcconfig

#include "path/to/xcconfigs/Platforms/iOS.xcconfig"
#include "path/to/xcconfigs/Targets/Application.xcconfig"
```

```none
// Application-Development.xcconfig

#include "Application-Common.xcconfig"
#include "path/to/Pods/Target Support Files/Pods-Application/Pods-Application.development.xcconfig"
```

```none
// Application-Staging.xcconfig

#include "Application-Common.xcconfig"
#include "path/to/Pods/Target Support Files/Pods-Application/Pods-Application.staging.xcconfig"
```

```none
// Application-Release.xcconfig

#include "Application-Common.xcconfig"
#include "path/to/Pods/Target Support Files/Pods-Application/Pods-Application.release.xcconfig"
```

```none
// Tests-Common.xcconfig

#include "path/to/xcconfigs/Platforms/iOS.xcconfig"
#include "path/to/xcconfigs/Targets/Tests.xcconfig"
```

```none
// Tests-Development.xcconfig

#include "Tests-Common.xcconfig"
#include "path/to/Pods/Target Support Files/Pods-Application/Pods-Tests.development.xcconfig"
```

```none
// Tests-Staging.xcconfig

#include "Tests-Common.xcconfig"
#include "path/to/Pods/Target Support Files/Pods-Application/Pods-Tests.staging.xcconfig"
```

```none
// Tests-Release.xcconfig

#include "Tests-Common.xcconfig"
#include "path/to/Pods/Target Support Files/Pods-Application/Pods-Tests.release.xcconfig"
```

### Step 4: Build the project!

Everything should be configured properly by now. Test the configuration by building the project. If it builds without errors, all is good!

If not, sorry... :trollface: [Please open an issue](https://github.com/netguru/xcconfigs/issues/new).
