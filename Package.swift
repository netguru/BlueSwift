// swift-tools-version:5.4
 import PackageDescription

 let package = Package(
     name: "BlueSwift",
     platforms: [ .iOS(.v10) ],
     products: [
         .library(
             name: "BlueSwift",
             targets: ["BlueSwift"]),
     ],    
     targets: [
         .target(
             name: "BlueSwift",
             path: "Framework/Source Files"
         ),
         .testTarget(name: "BlueSwiftTests",
                     dependencies: ["BlueSwift"],
                     path: "Unit Tests"
         ),
     ]
 )
