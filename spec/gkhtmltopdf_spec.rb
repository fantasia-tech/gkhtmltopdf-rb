require 'spec_helper'

RSpec.describe Gkhtmltopdf do
  describe '.convert' do
    let(:url) { 'https://f6a.net/oss/' }
    let(:output) { File.join(Dir.mktmpdir, 'output.pdf') }

    subject { Gkhtmltopdf.convert(url, output) }

    it 'successful conversion' do
      expect { subject }.not_to raise_error 
    end

    context 'invalid URL' do
      let(:url) { 'ftp://example.com' }
      it 'raises an error' do
        expect { subject }.to raise_error(Gkhtmltopdf::URLSchemeInvalid, 'Invalid URL scheme: (ftp)')
      end
    end
  end
  describe '.open' do
    let(:url) { 'https://f6a.net/oss/' }
    let(:output_path) { Dir.mktmpdir }

    subject do
      Gkhtmltopdf.open do |gk|
        (1..3).each { |n| gk.save_pdf("#{url}?test=#{n}", File.join(output_path, "#{n}.pdf")) }
      end
    end

    it 'successful conversion' do
      expect { subject }.to change { Dir.glob(File.join(output_path, '*.pdf')).count }.from(0).to(3)
      expect { subject }.not_to raise_error
    end

    context 'invalid URL' do
      let(:url) { 'ftp://example.com' }
      it 'raises an error' do
        expect { subject }.to raise_error(Gkhtmltopdf::URLSchemeInvalid, 'Invalid URL scheme: (ftp)')
      end
    end
  end
end
