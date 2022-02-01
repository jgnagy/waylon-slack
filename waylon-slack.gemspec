# frozen_string_literal: true

require_relative "lib/waylon/slack/version"

Gem::Specification.new do |spec|
  spec.name          = "waylon-slack"
  spec.version       = Waylon::Slack::VERSION
  spec.authors       = ["Jonathan Gnagy"]
  spec.email         = ["jonathan.gnagy@gmail.com"]

  spec.summary       = "Slack Sense for the Waylon Bot Framework"
  spec.description   = "Full Slack integration for the Waylon Bot Framework"
  spec.homepage      = "https://github.com/jgnagy/waylon-slack"
  spec.license       = "MIT"
  spec.required_ruby_version = "~> 3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jgnagy/waylon-slack"
  spec.metadata["changelog_uri"] = "https://github.com/jgnagy/waylon-slack/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "slack-ruby-client", "~> 1.0"
  spec.add_dependency "waylon-core", "~> 0.1"

  spec.add_development_dependency "bundler", "~> 2.3"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "rubocop", "~> 1.23"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubocop-rspec", "~> 2.6"
  spec.add_development_dependency "simplecov", "~> 0.21"
  spec.add_development_dependency "yard", "~> 0.9", ">= 0.9.27"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
