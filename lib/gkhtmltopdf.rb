# frozen_string_literal: true

require_relative 'gkhtmltopdf/version'
require_relative 'gkhtmltopdf/converter'
require_relative 'gkhtmltopdf/dsl'
require_relative 'errors'

module Gkhtmltopdf
  def self.convert(url, output_path, geckodriver_path: nil, firefox_path: nil, wait_time: nil, port: nil, user_agent: nil, gecko_stdout: nil, gecko_stderr: nil, print_options: {})
    converter = DSL.new
    converter.open(geckodriver_path: geckodriver_path, firefox_path: firefox_path, wait_time: wait_time, port: port, user_agent: user_agent, gecko_stdout: gecko_stdout, gecko_stderr: gecko_stderr)
    converter.save_pdf(url, output_path, print_options: print_options)
  ensure
    converter.close
  end

  def self.open(geckodriver_path: nil, firefox_path: nil, wait_time: nil, port: nil, user_agent: nil, gecko_stdout: nil, gecko_stderr: nil, &block)
    converter = DSL.new
    converter.open(geckodriver_path: geckodriver_path, firefox_path: firefox_path, wait_time: wait_time, port: port, user_agent: user_agent, gecko_stdout: gecko_stdout, gecko_stderr: gecko_stderr)
    yield converter
  ensure
    converter.close
  end
end
