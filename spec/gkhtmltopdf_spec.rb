require 'spec_helper'
require 'gkhtmltopdf'
require 'tmpdir'
require 'base64'

RSpec.describe Gkhtmltopdf do
  describe '.convert' do
    let(:url) { 'http://example.com' }
    let(:output) { File.join(Dir.mktmpdir, 'output.pdf') }
    let(:fake_pdf_base64) { Base64.encode64('PDFDATA') }

    before do
      # Stub Firefox path resolution to avoid system dependency
      allow_any_instance_of(Gkhtmltopdf::Converter).to receive(:resolve_firefox_path!).and_return('firefox')
      # Stub geckodriver existence check
      allow_any_instance_of(Gkhtmltopdf::Converter).to receive(:ensure_executable_exists!).and_return(nil)

      # Stub external process control
      allow(Kernel).to receive(:spawn).and_return(12_345)
      allow(Process).to receive(:kill).and_return(nil)
      allow(Process).to receive(:wait).and_return(nil)

      # Skip waiting for server and stub network interactions
      allow_any_instance_of(Gkhtmltopdf::Converter).to receive(:wait_for_server).and_return(nil)
      stub_session_id = 'abc123'
      allow_any_instance_of(Gkhtmltopdf::Converter).to receive(:create_session).and_return(stub_session_id)
      allow_any_instance_of(Gkhtmltopdf::Converter).to receive(:navigate).with(stub_session_id, url).and_return(nil)
      allow_any_instance_of(Gkhtmltopdf::Converter).to receive(:print_pdf).with(stub_session_id,
                                                                                {}).and_return(fake_pdf_base64)
      allow_any_instance_of(Gkhtmltopdf::Converter).to receive(:delete_session).with(stub_session_id).and_return(nil)
    end

    it 'converts the given URL to a PDF file' do
      Gkhtmltopdf.convert(url, output)
      expect(File).to exist(output)
      content = File.binread(output)
      expect(content).to eq('PDFDATA')
    end

    it 'passes print_options through to the converter' do
      options = { background: true, orientation: 'landscape' }
      allow_any_instance_of(Gkhtmltopdf::Converter).to receive(:print_pdf).with('abc123',
                                                                                options).and_return(fake_pdf_base64)
      Gkhtmltopdf.convert(url, output, print_options: options)
      expect(File).to exist(output)
      content = File.binread(output)
      expect(content).to eq('PDFDATA')
    end

    context 'when geckodriver is missing' do
      before do
        allow_any_instance_of(Gkhtmltopdf::Converter).to receive(:ensure_executable_exists!).with('nonexistent').and_raise(
          Gkhtmltopdf::Error, 'Geckodriver not found'
        )
      end

      it 'raises an error' do
        expect do
          Gkhtmltopdf.convert(url, output, geckodriver_path: 'nonexistent')
        end.to raise_error(Gkhtmltopdf::Error, /Geckodriver/)
      end
    end
  end
end
