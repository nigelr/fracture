# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fracture/version"

Gem::Specification.new do |s|
  s.name        = "fracture"
  s.version     = FractureVersion::VERSION
  s.authors     = ["Nigel Rausch"]
  s.email       = ["nigelr@brisbanerails.com"]
  s.homepage    = ""
  s.summary     = %q{Unified View testing within Views or Controllers for RSpec}
  s.description = %q{Fracture allows you to define and group view text or selectors in one place (at the top of a spec) and then refer to them with labels. This prevents issues when checking for existence and non existence of text/selectors if the views value changes only one spec will fail, using fracture you will update both instances}

  s.rubyforge_project = "fracture"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "rspec"

  s.add_development_dependency "rake"
end
