# xcconfigs – Tutorial

This document contains a tutorial on how to set up a new project using [netguru/xcconfigs](https://github.com/netguru/xcconfigs).

---

### Step 1: Install [netguru/xcconfigs](https://github.com/netguru/xcconfigs)

Start by installing [netguru/xcconfigs](https://github.com/netguru/xcconfigs). In this example we'll use Carthage.

Add the following dependency to your `Cartfile`:

```none
github "netguru/xcconfigs" {version}
```

Then, while in the root directory of your project, update the dependencies by running:

```sh
$ carthage update xcconfigs
```

This will add [netguru/xcconfigs](https://github.com/netguru/xcconfigs) to `Carthage/Checkouts/xcconfigs` directory.

### Step 2: Remove build settings from \*.xcodeproj file

Open your project and remove default build settings created by Xcode.

To do this, select the project in Navigator panel, go to Build Settings, select all by pressing `⌘A` and then nuke everything by pressing `⌫`. Repeat this step for all targets.

![](Images/usage-delete-build-settings.gif)

### Step 3: Create your custom \*.xcconfig files

In order to use [netguru/xcconfigs](https://github.com/netguru/xcconfigs), you need to create your own `*.xcconfig` files and `#include` appropriate [netguru/xcconfigs](https://github.com/netguru/xcconfigs) files in them.

In this example, we'll create configuration files for a sample iOS app and its test bundle and we'll use the following structure:

| File          | Purpose                                                     | Includes                                                       |
|:--------------|:------------------------------------------------------------|:---------------------------------------------------------------|
| `Base`        | Contains base build settings used by all targets.           | `xcconfigs/Common/Common`                                      |
| `Debug`       | Contains base build settings used in Debug configuration    | `Base`<br />`xcconfigs/Configurations/Debug`                   |
| `Release`     | Contains base build settings used in Release configuration. | `Base`<br />`xcconfigs/Configurations/Release`                 |
| `Application` | Contains build settings used by Application target.         | `xcconfigs/Platforms/iOS`<br />`xcconfigs/Targets/Application` |
| `Tests`       | Contains build settings used by Unit Tests target.          | `xcconfigs/Platforms/iOS`<br />`xcconfigs/Targets/Tests`       |

After this step, you should have the following directory tree:

```none
Root
 │
 ├ Carthage
 │  └ Checkouts
 │     └ xcconfigs
 │        └ ...
 │
 ├ Configuration
 │  ├ Base.xcconfig
 │  ├ Debug.xcconfig
 │  ├ Release.xcconfig
 │  ├ Application.xcconfig
 │  └ Tests.xcconfig       
 │
 ├ YourProject.xcodeproj
 │  └ ...
 │
 └ ...
```

Note that before you actually fill your own `*.xcconfig` files, the project **will not build**, as it's still missing the required build settings.

### Step 4: Fill your custom \*.xcconfig files

Now it's time to add appropriate `#include`s and build settings in your custom `*.xcconfig` files.

```none
// Base.xcconfig

#include "../Carthage/Checkouts/xcconfigs/Common/Common.xcconfig"

_BUILD_VERSION = 1.1
_DEPLOYMENT_TARGET_IOS = 8.0
```

```none
// Debug.xcconfig

#include "Base.xcconfig"
#include "../Carthage/Checkouts/xcconfigs/Configurations/Debug.xcconfig"
```

```none
// Release.xcconfig

#include "Base.xcconfig"
#include "../Carthage/Checkouts/xcconfigs/Configurations/Release.xcconfig"
```

```none
// Application.xcconfig

#include "../Carthage/Checkouts/xcconfigs/Platforms/iOS.xcconfig"
#include "../Carthage/Checkouts/xcconfigs/Targets/Application.xcconfig"

_BUNDLE_IDENTIFIER = com.example.foo
_BUNDLE_INFOPLIST_PATH = $(PROJECT_DIR)/Path/To/Application-Info.plist
```

```none
// Tests.xcconfig

#include "../Carthage/Checkouts/xcconfigs/Platforms/iOS.xcconfig"
#include "../Carthage/Checkouts/xcconfigs/Targets/Tests.xcconfig"

_BUNDLE_IDENTIFIER = com.example.foo.tests
_BUNDLE_INFOPLIST_PATH = $(PROJECT_DIR)/Path/To/Tests-Info.plist
```

For more information on build setting variables, see [Variables.md](Variables.md).

### Step 5: Update your Info.plist file

Now, in order to manage your build version, build number, bundle name and bundle identifier in your `Info.plist` files, you need to update them accordingly.

To do that, open both your app's and your unit tests bundle's `Info.plist` and change the following keys:

| Key                                                               | New Value                          |
|:------------------------------------------------------------------|:-----------------------------------|
| `CFBundleName`<br />(Bundle name)                                 | `$(PRODUCT_NAME)`                  |
| `CFBundleIdentifier`<br />(Bundle identifier)                     | `$(PRODUCT_BUNDLE_IDENTIFIER)`     |
| `CFBundleVersion`<br />(Bundle version)                           | `$(PRODUCT_BUNDLE_VERSION)`        |
| `CFBundleShortVersionString`<br />(Bundle versions string, short) | `$(PRODUCT_BUNDLE_VERSION_STRING)` |

After the change, the `Info.plist` should look like in the below screenshot:

![](Images/usage-update-info-plist.gif)

### Step 6: Assign configurations in \*.xcodeproj file

This is the final step.

Select the project file in Navigator panel, go to project's General tab and assign appropriate `*.xcconfig` files in the Configurations section:

![](Images/usage-assign-project-configurations.gif)

If Xcode can't see your custom `*.xcconfig` files, make sure they are included in the project.

### Step 7: Build the project!

Everything should be configured properly by now. Test the configuration by building the project. If it builds without errors, all is good!

![](Images/usage-build.gif)

If not, sorry... :trollface: [Please open an issue](https://github.com/netguru/xcconfigs/issues/new).
