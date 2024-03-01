# -*- encoding: utf-8 -*-
# stub: faraday-em_synchrony 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "faraday-em_synchrony".freeze
  s.version = "1.0.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/lostisland/faraday-em_synchrony", "homepage_uri" => "https://github.com/lostisland/faraday-em_synchrony", "source_code_uri" => "https://github.com/lostisland/faraday-em_synchrony" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["@iMacTia".freeze]
  s.date = "2021-04-26"
  s.description = "Faraday adapter for EM::Synchrony".freeze
  s.email = ["giuffrida.mattia@gmail.com".freeze]
  s.homepage = "https://github.com/lostisland/faraday-em_synchrony".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.5.6".freeze
  s.summary = "Faraday adapter for EM::Synchrony".freeze

  s.installed_by_version = "3.5.6".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<em-http-request>.freeze, [">= 1.1".freeze])
  s.add_development_dependency(%q<em-synchrony>.freeze, [">= 1.0.3".freeze])
  s.add_development_dependency(%q<faraday>.freeze, ["~> 1.0".freeze])
  s.add_development_dependency(%q<faraday-em_http>.freeze, ["~> 1.0".freeze])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.19.0".freeze])
  s.add_development_dependency(%q<multipart-parser>.freeze, ["~> 0.1.1".freeze])
  s.add_development_dependency(%q<webmock>.freeze, ["~> 3.4".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.91.1".freeze])
  s.add_development_dependency(%q<rubocop-packaging>.freeze, ["~> 0.5".freeze])
  s.add_development_dependency(%q<rubocop-performance>.freeze, ["~> 1.0".freeze])
end
