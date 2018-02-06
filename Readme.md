# Bluetooth Open Source Library

![](https://img.shields.io/badge/swift-4.0-orange.svg)

An open source Bluetooth library providing a clean interface for interacting with remote Bluetooth devices. It allows connecting, reading and writng data over Bluetooth. See the sample app for a basic usage describtion.

## Team

* [Jan Posz](mailto:jan.posz@netguru.co) - Product Owner, iOS Developer

## Tools & Services

* Tools:
  * Xcode 9.2 with latest iOS SDK (11.2)
* Services:
  * [JIRA](https://netguru.atlassian.net/projects/IOS/issues)

## Configuration

### Instalation

1. Clone repository:

  ```bash
  # over https:
  git clone https://github.com/netguru/bluetooth.git
  # or over SSH:
  git clone git@github.com:netguru/bluetooth.git
  ```
  
2. Open `Bluetooth.xcodeproj` file and build the project.
 
 
## Coding guidelines

- Respect Swift [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- The code must be readable and self-explanatory - full variable names, meaningful methods, etc.
- Don't leave any commented-out code.
- Write documentation for every method and property accessible outside the class. For example well documented method looks as follows:
  
  for **Swift**:
  
  ```swift
  /// Tells the magician to perform a given trick.
  ///
  /// - Parameter trick: The magic trick to perform.
  /// - Returns: Whether the magician succeeded in performing the magic trick.
  func perform(magicTrick trick: MagicTrick) -> Bool {
    // body
  }
  ```

