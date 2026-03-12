# frozen_string_literal: true

require_relative "gkhtmltopdf/version"
require_relative "gkhtmltopdf/converter"

module Gkhtmltopdf
  class Error < StandardError; end
  
  def self.convert(url, output_path, geckodriver_path: nil, firefox_path: nil, port: nil, print_options: {})
    converter = Converter.new(geckodriver_path: geckodriver_path, firefox_path: firefox_path, port: port)
    converter.convert(url, output_path, print_options: print_options)
  end
end
