# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
require File.expand_path('../lib/acts_as_monitor/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "usefull_table"
  s.summary = "Table Helper with Excel export, inline editing and monitoring funxtions"
  s.description = "Table Helper with Excel export, inline editing and monitoring funxtions"
  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.rdoc"]
  s.version = UsefullTable::VERSION
end