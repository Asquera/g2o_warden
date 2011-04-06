# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "g2o"
  s.version     = "1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Felix Gilcher"]
  s.email       = ["felix.gilcher@asquera.de"]
  s.summary     = %q{A g2o warden strategy}
  s.description = %q{A warden strategy that validates a g2o request.}
  
  s.files = %w( README.md Rakefile LICENSE )
  s.files += Dir.glob("lib/**/*")
  
  s.require_paths = ["lib"]
end
