# xcconfigs – Best Practices

Each project has best practices on how to do various things, and [netguru/xcconfigs](https://github.com/netguru/xcconfigs) is no exception.

---

### Prefer creating custom build setting variables instead of new xcconfig files

In case you need more control over which build setting is used in which target and configuration, instead of creating multiple `.xcconfig` files with similar, but slightly various content, prefer to create custom variables and map those to the real build settings instead.

For example, in case you need to use different Bundle Identifier for multiple build configurations, prefer the following setup:

```none
// Application.xcconfig

_BUNDLE_IDENTIFIER = com.example.app$(__BUNDLE_IDENTIFIER_SUFFIX)
```

```none
// Development.xcconfig

__BUNDLE_IDENTIFIER_SUFFIX = .development
```

```none
// Staging.xcconfig

__BUNDLE_IDENTIFIER_SUFFIX = .staging
```

Instead of this setup:

```none
// Application-Development.xcconfig

_BUNDLE_IDENTIFIER = com.example.app.development
```

```none
// Application-Staging.xcconfig

_BUNDLE_IDENTIFIER = com.example.app.staging
```

```none
// Application-Release.xcconfig

_BUNDLE_IDENTIFIER = com.example.app
```

_Rationale: Keeping `.xcconfig` files simple and using custom build setting variables makes your configuration more maintainable and easier to understand for newcomers._

---

### Prefix your custom build setting variables by double underscore

If you use custom build setting variables, prefix them by double underscore `__`.

For example, **prefer this name**:

```none
__FOO =
```

Instead of these names:

```none
_BAR =
BAZ =
```

_Rationale: Build settings with no underscores are "real build settings" used by compiler and understood by Xcode. Build settings with one underscore are used by [netguru/xcconfigs](https://github.com/netguru/xcconfigs). By using double underscore, you minimize the risk of accidentally overriding build settings from any of aforementioned places._

---

### Use variables provided by [netguru/xcconfigs](https://github.com/netguru/xcconfigs) instead of real build settings

In case you need to customize build settings, prefer to override [variables](Variables.md) provided by [netguru/xcconfigs](https://github.com/netguru/xcconfigs).

Additionally, try to inherit defult build settings by putting `$(inherited)` as a value of build setting that support inheritance.

In other words, **prefer this**:

```none
_COMPILER_FRAMEWORK_SEARCH_PATHS = $(inherited) $(PROJECT_DIR)/Custom/Path/To/Frameworks
```

Instead of this:

```none
FRAMEWORK_SEARCH_PATHS = $(PROJECT_DIR)/Custom/Path/To/Frameworks
```

_Rationale: [netguru/xcconfigs](https://github.com/netguru/xcconfigs) uses some reasonable default values for many build settings and some of them are even composed out of many variables._

---

### Don't fight Xcode in case of problems

[netguru/xcconfigs](https://github.com/netguru/xcconfigs) are here to help you, not interfere with or disable your work.

If Xcode throws strange errors during compilation (or runtime), you suspect it's caused by using this project and you don't know how to fix it, let Xcode win (by using build settings in `*.xcodeproj` file or getting rid of `*.xcconfig` files at all).

In addition, in case of problems, you are encouraged to [open an issue](https://github.com/netguru/xcconfigs/issues/new) so that our maintainers can help you.

_Rationale: You don't want to fight your IDE._
