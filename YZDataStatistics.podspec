Pod::Spec.new do |s|
    
    s.name          = 'YZDataStatistics'
    s.version       = '1.0'
    s.summary       = 'YZDataStatistics'
    s.homepage      = 'https://github.com/hustwyz/YZDataStatistics'
    s.author        = { 'Wang Yunzhen' => 'hustwyz@gmail.com' }
    s.platform      = :ios, '6.0'
    s.source        = {
        :git => 'https://github.com/hustwyz/YZDataStatistics.git',
        :tag => s.version.to_s
    }
    s.source_files = 'YZDataStatistics/*.{h,m}'
    s.license = 'MIT'
    s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/YZDataStatistics"' }
    s.framework = 'UIKit'
    s.requires_arc = false

end
