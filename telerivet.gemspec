Gem::Specification.new do |s|
  s.name        = 'telerivet'
  s.version     = '1.6.1'
  s.date        = '2022-07-18'
  s.summary     = "Telerivet REST API Client"
  s.description = "Ruby client library for Telerivet REST API"
  s.authors     = ["Jesse Young"]
  s.email       = 'support@telerivet.com'
  s.files       = ["lib/telerivet.rb", "lib/cacert.pem"] + Dir.glob("lib/telerivet/*")
  s.homepage    = 'http://telerivet.com'
  s.license     = 'MIT'
end