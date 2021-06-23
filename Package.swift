// swift-tools-version:5.4
 import PackageDescription

 let package = Package(
     name: "BlueSwift",
     platforms: [ .iOS(.v9) ],
     products: [
         .library(
             name: "BlueSwift",
             targets: ["BlueSwift"]),
     ],    
     targets: [
         .target(
             name: "BlueSwift",
             path: "BlueSwiftKit"
         ),
         .testTarget(name: "BlueSwiftTests",
                     dependencies: ["BlueSwift"],
                     path: "Tests/BlueSwiftKitTests"
         ),
     ]
 )
