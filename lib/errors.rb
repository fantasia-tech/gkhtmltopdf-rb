module Gkhtmltopdf
  class Error < StandardError; end

  class PathUnresolvedError < Error
    def initialize(name)
      message = "#{name} is not found. Please ensure #{name} is installed and either in your PATH or specify the path during initialization."
      super(message)
    end
  end

  class BrowserError < Error; end

  class URLSchemeInvalid < Error
    def initialize(url_scheme)
      message = "Invalid URL scheme: (#{url_scheme})"
      super(message)
    end
  end
end
