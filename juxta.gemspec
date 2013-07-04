Gem::Specification.new do |s|
  s.name        = 'juxta'
  s.version     = '0.1.0'
  s.date        = '2013-07-24'
  s.summary     = "JuxtaWS Ruby bindings"
  s.description = "JuxtaWS Ruby bindings"
  s.authors     = ["Nick Laiacona"]
  s.email       = 'nick@performantsoftware.com'
  s.files       = ["lib/juxta.rb", "lib/juxta/connection.rb", "lib/juxta/utilities.rb"]
  s.add_runtime_dependency "rest-client", ["= 1.6.7"]
  s.add_runtime_dependency "json", ["= 1.7.7"]
  s.add_runtime_dependency "OptionParser", ["= 0.5.1"]
  s.add_runtime_dependency "uuidtools", ["= 2.1.3"]
  s.homepage    =
    'http://rubygems.org/gems/juxta'
end

