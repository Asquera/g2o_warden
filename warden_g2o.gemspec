# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "warden_g2o"
  s.version     = "1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Felix Gilcher"]
  s.email       = ["felix.gilcher@asquera.de"]
  s.summary     = %q{A G2O warden strategy}
  s.description = %q{A warden strategy that validates an akamai G2O request.}
  
  s.files = %w( README.md Rakefile LICENSE )
  s.files += Dir.glob("lib/**/*")
  
  s.require_paths = ["lib"]
end
