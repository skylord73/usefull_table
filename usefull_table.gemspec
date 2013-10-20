# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
require File.expand_path('../lib/usefull_table/version', __FILE__)

Gem::Specification.new do |s|
  s.authors        = ["Andrea Bignozzi"]
  s.email            = ["skylord73@gmail.com"]
  s.description = "Table Helper with Excel export, inline editing and monitoring funxtions"
  s.summary = "Table Helper with Excel export, inline editing and monitoring funxtions"
  
  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.rdoc", "CHANGELOG.md"]
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files      = s.files.grep(%r{^(test|spec|features)/})
  s.name = "usefull_table"
  s.require_paths   = ["lib"]
  s.version = UsefullTable::VERSION
  
  s.add_dependency "rails", "~>3.0.14"
  s.add_dependency "axlsx", "<1.3.6"
  s.add_dependency "acts_as_xls"
  s.add_dependency "meta_search"
  s.add_dependency "will_paginate"
  
end
