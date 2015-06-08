Pod::Spec.new do |spec|
  spec.name             = 'libvarobjc'
  spec.version          = '1.0.0'
  spec.license          =  { :type => 'MIT' } 
  spec.homepage         = 'https://github.com/claybridges/libvarobjc'
  spec.authors          = { 'Luca DAlberti' => 'dalberti.luca93@gmail.com' }
  spec.summary          = 'A tiny library of Objective-C macros to aid concision, @morph, @var and @with. In use, code completion and Xcode indentation work sanely.'
  spec.source           = { :git => 'https://github.com/dalu93/libvarobjc.git', :tag => '1.0.0'  }
  spec.source_files     = 'varobjc/VARMacros.h'
end