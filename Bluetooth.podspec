Pod::Spec.new do |spec|
  spec.name             = 'Bluetooth'
  spec.version          = '1.0.0'
  spec.license          = { :type => 'MIT' }
  spec.homepage         = 'https://github.com/netguru/bluetooth'
  spec.authors          = { 'Jan Posz' => 'jan.posz@netguru.co' }
  spec.summary          = 'Easy and lightweight CoreBluetooth wrapper written in Swift.'
  spec.source           = { :git => 'https://github.com/netguru/BlueSwift.git', :tag => 'v1.0.0-alpha' }
  spec.source_files     = 'Framework/*.swift'
  spec.framework        = 'CoreBluetooth'
  spec.requires_arc     = true
end