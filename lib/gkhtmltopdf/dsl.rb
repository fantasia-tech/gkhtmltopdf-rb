module Gkhtmltopdf
  class DSL
    def initialize
      @converter = Converter.new
    end

    def open(options)
      @converter.open(**options)
    end

    def close
      @converter.close
    end

    def save_pdf(url, output_path, print_options: {})
      @converter.save_pdf(url, output_path, print_options: print_options)
    end
  end
end
