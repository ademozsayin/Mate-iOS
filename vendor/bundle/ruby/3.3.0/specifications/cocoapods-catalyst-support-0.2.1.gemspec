# -*- encoding: utf-8 -*-
# stub: cocoapods-catalyst-support 0.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "cocoapods-catalyst-support".freeze
  s.version = "0.2.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["fermoya".freeze]
  s.date = "2022-03-30"
  s.description = "Helps you configure your Catalyst dependencies.".freeze
  s.email = ["fmdr.ct@gmail.com".freeze]
  s.homepage = "https://github.com/fermoya/cocoapods-catalyst-support".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.5.6".freeze
  s.summary = "Many libraries you may use for iOS won't compile for your macCatalyst App, thus, making porting your App to the Mac world more difficult than initially expected. This is due to those libraries not being compiled for `x86_64`. `cocoapods-catalyst-support` helps you configure which libraries you'll be using for iOS and which for macCatalyst.".freeze

  s.installed_by_version = "3.5.6".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<colored2>.freeze, ["~> 3.1".freeze])
  s.add_runtime_dependency(%q<cocoapods>.freeze, ["~> 1.9".freeze])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 2.3".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 12.3.3".freeze])
end
