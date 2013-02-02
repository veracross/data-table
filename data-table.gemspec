# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "data-table/version"

Gem::Specification.new do |s|
  s.name        = "data-table"
  s.version     = DataTable::VERSION
  s.authors     = ["Steve Erickson", "Jeff Fraser"]
  s.email       = ["sixfeetover@gmail.com"]
  s.homepage    = "https://github.com/sixfeetover/data-table"
  s.summary     = %q{Turn arrays of hashes or models in to an HTML table.}
  s.description = %q{data-table is a simple gem that provides a DSL for turning an array of hashes or ActiveRecord objects into an HTML table.}

  s.rubyforge_project = "data-table"

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
