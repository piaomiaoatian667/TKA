Pod::Spec.new do |s|
  s.name = "TKA"
  s.version = "0.1.19"
  s.summary = "TKA. cbc"
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"piaomiaoatian667"=>"piaomiaoatian@yeah.com"}
  s.homepage = "https://github.com/piaomiaoatian667/TKA"
  s.description = "TKA. cbc doopool"
  s.source = -force

  s.ios.deployment_target    = '8.0'
  s.ios.vendored_framework   = 'ios/TKA.framework'
end
