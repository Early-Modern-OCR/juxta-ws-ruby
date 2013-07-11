Gem::Specification.new do |s|
  s.name        = 'juxta'
  s.version     = '0.2.0'
  s.date        = '2013-07-10'
  s.summary     = "Provides a Ruby interface to the JuxtaWS REST web service."
  s.description = "JuxtaWS can collate two or more versions of the same textual work (“witnesses”) and generate a list of alignments as well as two different styles of visualization suitable for display on the web. This gem provides a Ruby interface to the JuxtaWS REST web service."
  s.license     = 'Apache 2.0'
  s.authors     = ["Lou Foster", "Dave Goldstein", "Nick Laiacona"]
  s.email       = 'nick@performantsoftware.com'
  s.files       = ["lib/juxta.rb", "lib/juxta/connection.rb", "lib/juxta/utilities.rb"]
  s.add_runtime_dependency "rest-client", ["= 1.6.7"]
  s.add_runtime_dependency "json", ["= 1.7.7"]
  s.add_runtime_dependency "OptionParser", ["= 0.5.1"]
  s.add_runtime_dependency "uuidtools", ["= 2.1.3"]
  s.required_ruby_version = '>= 1.9.2'
  s.homepage    =
    'http://rubygems.org/gems/juxta'
end

