# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "data-table/version"

Gem::Specification.new do |s|
  s.name        = "data-table"
  s.version     = DataTable::VERSION
  s.licenses    = ['Nonstandard']
  s.authors     = ["Steve Erickson", "Jeff Fraser"]
  s.email       = ["sixfeetover@gmail.com"]
  s.homepage    = "https://github.com/sixfeetover/data-table"
  s.summary     = %(Turn arrays of hashes or models in to an HTML table.)
  s.description = %(data-table is a simple gem that provides a DSL for
                    turning an array of hashes or ActiveRecord objects into an
                    HTML table.)

  s.rubyforge_project = "data-table"

  s.add_development_dependency 'rake', '~> 11'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'guard', '~> 2'
  s.add_development_dependency 'guard-rspec', '~> 4'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
