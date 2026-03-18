# frozen_string_literal: true

require_relative 'lib/gkhtmltopdf/version'

Gem::Specification.new do |spec|
  spec.name = 'gkhtmltopdf'
  spec.version = Gkhtmltopdf::VERSION
  spec.authors = ['Kazuki Sakane']
  spec.email = ['sakane@f6a.net']
  spec.license = 'MIT'

  spec.summary = 'Gkhtmltopdf is mean Gecko HTML to PDF converter.'
  spec.description = <<~EOS
    Developed as an alternative to wkhtmltopdf.
    This gem converts HTML to PDF using Firefox's Geckodriver.
  EOS

  spec.homepage = "https://f6a.net/oss/"
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "https://github.com/fantasia-tech/gkhtmltopdf-rb"
  spec.metadata['changelog_uri'] = "https://github.com/fantasia-tech/gkhtmltopdf-rb/blob/main/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .github/])
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # requirements
  spec.requirements << 'Firefox'
  spec.requirements << 'Geckodriver'

  # dependency
  spec.add_dependency 'base64', '~> 0.2'
  spec.add_development_dependency 'irb'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov', '~> 0.22'

  spec.post_install_message = <<~MSG
    =====================================================================
    Gkhtmltopdf has been installed successfully. 🎉

    ⚠️ Caution
    Required: To run this gem, you need to have `firefox` and `geckodriver` installed and added to your PATH.

    check [readme.md](https://github.com/fantasia-tech/gkhtmltopdf-rb/blob/main/README.md) for more details.
    =====================================================================
  MSG
end
