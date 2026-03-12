require 'spec_helper'
require 'gkhtmltopdf'
require 'tmpdir'
require 'base64'

RSpec.describe Gkhtmltopdf do
  describe '.convert' do
    let(:url) { 'https://f6a.net/oss/' }
    let(:output) { File.join(Dir.mktmpdir, 'output.pdf') }
    let(:hash) { {} }

    subject { Gkhtmltopdf.convert(url, output, **hash) }

    it 'successful conversion' do
      expect { subject }.not_to raise_error 
    end

    context 'invalid URL' do
      let(:url) { 'ftp://example.com' }
      it 'raises an error' do
        expect { subject }.to raise_error(Gkhtmltopdf::Error, 'Invalid URL scheme: ftp')
      end
    end
  end
end
