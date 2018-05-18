# xcconfigs – Code Signing

Large-scale apps, especially the ones crated by a team of numerous people and having more than two (debug/release) build configurations, need powerful and flexible way of specifying code signing settings per each target and configuration.

In this document you will see a couple of methods to do flexible manual code signing using [netguru/xcconfigs](https://github.com/netguru/xcconfigs).

---

### Method 1: Using custom build setting variables

The first method is to map `_CODESIGN_*` build settings to custom build setting variables declared in configuration `.xcconfig` files.

The following example assumes that `.xcconfig` files are assigned as follows:

```none
Development - Development.xcconfig
 ├ Application - Application.xcconfig
 └ Tests - Tests.xcconfig

Staging - Staging.xcconfig
 ├ Application - Application.xcconfig
 └ Tests - Tests.xcconfig

Release - Release.xcconfig
 ├ Application - Application.xcconfig
 └ Tests - Tests.xcconfig
```

In `Application.xcconfig` and `Tests.xcconfig` map `_CODESIGN_*` build settings to custom build settings variables that we will use in the next step:

```none
// Application.xcconfig

_CODESIGN_STYLE = Manual
_CODESIGN_DEVELOPMENT_TEAM = $(__APPLICATION_CODESIGN_DEVELOPMENT_TEAM)
_CODESIGN_IDENTITY = $(__APPLICATION_CODESIGN_IDENTITY)
_CODESIGN_PROFILE_SPECIFIER = $(__APPLICATION_CODESIGN_PROFILE_SPECIFIER)
```

Then, in `Development.xcconfig`, `Staging.xcconfig` and `Release.xcconfig` set values of previously mentioned custom build setting variables:

```none
// Staging.xcconfig

__APPLICATION_CODESIGN_DEVELOPMENT_TEAM = A1B2C3D4E5F6
__APPLICATION_CODESIGN_IDENTITY = John Doe (A1B2C3D4E5F6)
__APPLICATION_CODESIGN_PROFILE_SPECIFIER = MyProject Staging
```

```none
// Release.xcconfig

__APPLICATION_CODESIGN_DEVELOPMENT_TEAM = F6E5D4C3B2A1
__APPLICATION_CODESIGN_IDENTITY = Jane Roe (F6E5D4C3B2A1)
__APPLICATION_CODESIGN_PROFILE_SPECIFIER = MyProject Release
```

There are two things worth noting about this example.

Firstly, notice that `Development.xcconfig` does not set `__APPLICATION_CODESIGN_*` custom build setting variables because you'd probably don't want your debug builds to be code signed.

Secondly, notice that unit tests bundle target remains not code signed, as `Tests.xcconfig` does not use `__APPLICATION_CODESIGN_*` custom build setting variables.

If you want your unit tests bundle to be code signed (or you have another target that needs to be code signed), you can use the above method to define more custom build setting variables accordingly (such as `__TESTS_CODESIGN_*` in `Tests.xcconfig`).

---

### Method 2: Using multiple xcconfig files

The second method is to use multiple `.xcconfig` files, one per target per build configuration.

The following example assumes that `.xcconfig` files are assigned as follows:

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

In such case, you can directly set `_CODESIGN_*` build settings in `Application-Staging.xcconfig` and `Application-Release.xcconfig` files:

```none
// Application-Staging.xcconfig

_CODESIGN_STYLE = Manual
_CODESIGN_DEVELOPMENT_TEAM = A1B2C3D4E5F6
_CODESIGN_IDENTITY = John Doe (A1B2C3D4E5F6)
_CODESIGN_PROFILE_SPECIFIER = MyProject Staging
```

```none
// Application-Release.xcconfig

_CODESIGN_STYLE = Manual
_CODESIGN_DEVELOPMENT_TEAM = F6E5D4C3B2A1
_CODESIGN_IDENTITY = Jane Roe (F6E5D4C3B2A1)
_CODESIGN_PROFILE_SPECIFIER = MyProject Release
```

Like after the first method, `Application-Development.xcconfig` does not set `_CODESIGN_*` build settings and, as neither do `Tests-*.xcconfig` files, unit tests bundle remains not code signed.

Using this method, as opposed to the first method, does get rid of custom build setting variables. However, it requires 9, instead of 5 `.xcconfig` files to be created. It is up to you and your team mates to decide which method suits you better.
