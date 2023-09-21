# frozen_string_literal: true

require_relative "lib/dividendo_crawler/version"

Gem::Specification.new do |spec|
  spec.name = "dividendo_crawler"
  spec.version = DividendoCrawler::VERSION
  spec.authors = ["Marco Carvalho"]
  spec.email = ["marco.carvalho.swasthya@gmail.com"]

  spec.summary = "summary"
  spec.description = "longer"
  spec.homepage = "https://github.com"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "faraday", "~> 2.7.3"
  spec.add_dependency "activerecord", "~> 7.0", ">= 7.0.4.2"
  spec.add_dependency "pg", "~> 1.4", ">= 1.4.6"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "byebug", "~> 11.1"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubocop-rspec", "~> 2.18"
  spec.add_development_dependency "vcr", "~> 6.1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
