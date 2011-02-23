# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "stripe"
  s.version     = '1.3.5'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Stripe Team"]
  s.email       = ["info@stripe.com"]
  s.homepage    = ""
  s.summary     = %q{Provies ruby bindings for Stripe}
  s.description = %q{Provies ruby bindings for Stripe}

  s.rubyforge_project = "stripe"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency 'json', [">= 1.4.0"]
  s.add_dependency 'rest-client', [">= 1.4.1"]
end
