# coding: utf-8
# Copyright (c) 2016 Freescale Semiconductor Inc.
Gem::Specification.new do |spec|
  spec.name          = "duxml"
  spec.version       = "0.9.0"
  spec.summary       = "Dynamic Universal XML"
  spec.description   = "see README.md"
  spec.authors       = ["Peter Kong"]
  spec.email         = ["peter.kong@nxp.com"]
  spec.homepage      = "http://www.github.com/Ludocracy/duxml"
  spec.license       = "MIT"

  spec.required_ruby_version     = '>= 1.9.3'
  spec.required_rubygems_version = '>= 1.8.11'

  # Only the files that are hit by these wildcards will be included in the
  # packaged gem, the default should hit everything in most cases but this will
  # need to be added to if you have any custom directories
  spec.files         = Dir["lib/**/*.rb"]
  spec.executables   = ["validate_xml"]
  spec.require_paths = ["lib"]

  # Add any gems that your plugin needs to run within a host application
  spec.add_runtime_dependency "ox", "~> 2.3"
  spec.add_runtime_dependency "rubyXL", "~> 3.3"

  # Add any gems that your plugin needs for its development environment only
end
