# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "Website"
  spec.version       = "1.1.0"
  spec.authors       = ["Karl Nicoll"]
  spec.email         = ["karl@karlnicoll.net"]

  spec.summary       = "My personal website"
  spec.homepage      = "https://github.com/karlnicoll/website"
  spec.licenses       = ["MIT", "CC-BY-4.0"]

  spec.metadata = {
    "source_code_uri"   => "https://github.com/karlnicoll/website"
  }

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r!^(assets|_layouts|_includes|_sass|LICENSE|README|_config\.yml)!i) }

  spec.add_runtime_dependency "jekyll-oceanic", "~> 1.1"
  spec.add_runtime_dependency "jekyll-sitemap", "~> 1.4"
  spec.add_runtime_dependency "webrick", "~> 1.7"

  spec.add_development_dependency "bundler", "~>2.1"
end

