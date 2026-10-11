# frozen_string_literal: true

require_relative "lib/sdtoolkit/version"

Gem::Specification.new do |spec|
  spec.name = "sdtoolkit"
  spec.version = SDToolkit::VERSION
  spec.authors = ["Ramesh-xyz"]
  spec.summary = "Standard deviation, variance, sum of squares, RSD and coefficient of variation"
  spec.description = "Dependency-free population and sample standard deviation, variance, " \
                     "sum of squared deviations, relative standard deviation and coefficient " \
                     "of variation, with strict input validation and a numerically stable " \
                     "two-pass algorithm."
  spec.homepage = "https://standarddeviationcalculator.net/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/Ramesh-xyz/statistics-calculator-toolkit/tree/main/ruby",
    "documentation_uri" => "https://ramesh-xyz.github.io/statistics-calculator-toolkit/",
    "bug_tracker_uri" => "https://github.com/Ramesh-xyz/statistics-calculator-toolkit/issues",
    "changelog_uri" => "https://github.com/Ramesh-xyz/statistics-calculator-toolkit/blob/main/CHANGELOG.md"
  }
  # rubygems_mfa_required is not set because releases are pushed from GitHub
  # Actions with a scoped API key (.github/workflows/publish-ruby.yml). Switch
  # to RubyGems trusted publishing before turning it on.

  spec.files = ["lib/sdtoolkit.rb", "lib/sdtoolkit/version.rb", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]
end
