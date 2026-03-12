require 'net/http'
require 'json'
require 'base64'
require 'uri'
require 'socket'

module Gkhtmltopdf
  class Converter
    def initialize(geckodriver_path: nil, firefox_path: nil, port: nil)
      @geckodriver_path = resolve_geckodriver_path!(geckodriver_path)
      @firefox_path = resolve_firefox_path!(firefox_path)
      @port = port || get_free_port
      @base_url = "http://127.0.0.1:#{@port}"
    end

    def convert(url, output_path, print_options: {})
      validate_url_scheme!(url)

      pid = spawn("#{@geckodriver_path} --port #{@port}", out: File::NULL, err: File::NULL)
      wait_for_server

      session_id = nil
      begin
        session_id = create_session
        navigate(session_id, url)
        
        pdf_base64 = print_pdf(session_id, print_options)
        File.binwrite(output_path, Base64.decode64(pdf_base64))
      ensure
        delete_session(session_id) if session_id
        begin
          Process.kill('TERM', pid)
          Process.wait(pid)
        rescue Errno::ESRCH, Errno::ECHILD
          # nothing to do if the process is already terminated
        end
      end
    end

    private

    def get_free_port
      server = TCPServer.new('127.0.0.1', 0)
      port = server.addr[1]
      server.close
      port
    end

    def resolve_geckodriver_path!(provided_path)
      path = provided_path || find_default_geckodriver
      unless path
        raise Error, "Geckodriver is not found. Please ensure Geckodriver is installed and either in your PATH or specify the path during initialization."
      end
      path
    end

    def resolve_firefox_path!(provided_path)
      path = provided_path || find_default_firefox
      unless path
        raise Error, "Firefox is not found. Please ensure Firefox is installed and either in your PATH or specify the path during initialization."
      end
      path
    end

    def executable_exists?(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].to_s.split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return true if File.executable?(exe) && !File.directory?(exe)
        end
      end
      false
    end

    def find_default_geckodriver
      return 'geckodriver' if executable_exists?('geckodriver')
      nil
    end

    def find_default_firefox
      return 'firefox' if executable_exists?('firefox')

      common_paths = [
        '/Applications/Firefox.app/Contents/MacOS/firefox',
        'C:/Program Files/Mozilla Firefox/firefox.exe',
        'C:/Program Files (x86)/Mozilla Firefox/firefox.exe'
      ]
      common_paths.find { |path| File.executable?(path) && !File.directory?(path) }
    end

    def wait_for_server
      10.times do
        begin
          Net::HTTP.get(URI("#{@base_url}/status"))
          return
        rescue Errno::ECONNREFUSED
          sleep 0.2
        end
      end
      raise Error, "Failed to launch geckodriver (port #{@port})"
    end

    def post(path, payload)
      uri = URI("#{@base_url}#{path}")
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = payload.to_json
      res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

      begin
        JSON.parse(res.body)
      rescue JSON::ParserError
        raise Error, "Invalid geckodriver response (Status: #{res.code}): #{res.body}"
      end
    end

    def create_session
      firefox_options = { args: ["-headless"] }
      firefox_options[:binary] = @firefox_path if @firefox_path != 'firefox'

      payload = {
        capabilities: {
          alwaysMatch: {
            browserName: "firefox",
            "moz:firefoxOptions": firefox_options
          }
        }
      }

      response = post("/session", payload)
      value = response["value"]
      raise Error, "Failed to launch Firefox: #{value}" if value["error"]

      value["sessionId"]
    end

    def navigate(session_id, url)
      post("/session/#{session_id}/url", { url: url })
    end

    def print_pdf(session_id, user_options)
      default_options = {
        background: false,
        shrinkToFit: true,
        orientation: "portrait",
        page: { width: 21.0, height: 29.7 },
        margin: { top: 1.0, bottom: 1.0, left: 1.0, right: 1.0 }
      }

      payload = default_options.merge(user_options)

      response = post("/session/#{session_id}/print", payload)
      value = response["value"]
      raise Error, "Failed to generate PDF: #{value}" if value["error"]

      value
    end

    def delete_session(session_id)
      uri = URI("#{@base_url}/session/#{session_id}")
      req = Net::HTTP::Delete.new(uri)
      Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
    end

    def validate_url_scheme!(url_string)
      parsed_url = URI.parse(url_string)
      allowed_schemes = ['http', 'https', 'file']
      raise Error, 'URL scheme is nil' if parsed_url.scheme.nil?
      unless allowed_schemes.include?(parsed_url.scheme)
        raise Error, "Invalid URL scheme: #{parsed_url.scheme}"
      end
    end
  end
end
