require 'spec_helper'

RSpec.describe Gkhtmltopdf::Converter do
  let(:converter) { Gkhtmltopdf::Converter.new }
  after { converter.close }
  describe '#open' do
    subject { converter.open }
    it {
      subject
      expect(converter.instance_variable_get(:@geckodriver_path)).to be_a(String)
      expect(converter.instance_variable_get(:@firefox_path)).to be_a(String)
      expect(converter.instance_variable_get(:@port)).to be_a(Integer)
      expect(converter.instance_variable_get(:@base_url)).to be_a(String)
      expect(converter.instance_variable_get(:@pid)).to be_a(Integer)
      expect(converter.instance_variable_get(:@session_id)).to be_a(String)
    }
  end
  describe '#save_pdf' do
    before { converter.open }
    subject { converter.save_pdf(url, output_path) }
    let(:url) { "file://#{file_fixture('test.html')}" }
    let(:output_path) { File.join(Dir.mktmpdir, 'output.pdf') }
    it {
      expect { subject }.to change { Dir.glob(output_path).count }.from(0).to(1)
      expect(File.binread(output_path)).to include('/FontName')
    }
  end
  describe '#resolve_geckodriver_path!' do
    subject { converter.send(:resolve_geckodriver_path!, nil) }
    context 'geckodriver is not available' do
      before { allow(File).to receive(:executable?).and_return(false) }
      it 'raises an error' do
        expect { subject }.to raise_error(Gkhtmltopdf::PathUnresolvedError, /\AGeckodriver is not found./)
      end
    end
  end

  describe '#resolve_firefox_path!' do
    subject { converter.send(:resolve_firefox_path!, nil) }
    context 'firefox is not available' do
      before { allow(File).to receive(:executable?).and_return(false) }
      it 'raises an error' do
        expect { subject }.to raise_error(Gkhtmltopdf::PathUnresolvedError, /\AFirefox is not found./)
      end
    end
  end

  describe '#wait_for_gk' do
    subject { converter.send(:wait_for_gk, 0) }
    context 'fail launch geckodriver' do
      before { allow(Net::HTTP).to receive(:get).and_raise(Errno::ECONNREFUSED, 'Dummy error') }
      it 'raises an error' do
        expect { subject }.to raise_error(Gkhtmltopdf::BrowserError, /\AFailed to launch geckodriver \(port \)\Z/)
      end
    end
  end

  describe '#post' do
    subject { converter.send(:post, '/dummy', {test: :value}) }
    context 'Invalid json response from geckodriver' do
      before {
        converter.instance_variable_set(:@base_url, 'http://test')
        allow(Net::HTTP).to receive(:start).and_return(Struct.new(:code, :body).new('200', 'invalid_json: 0123'))
      }
      it 'raises an error' do
        expect { subject }.to raise_error(Gkhtmltopdf::BrowserError, 'Invalid json response (Status: 200): invalid_json: 0123')
      end
    end
  end

  describe '#validate_url_scheme!' do
    subject { converter.send(:validate_url_scheme!, url_string) }
    let(:url_string) { 'http://f6a.net' }
    it { expect { subject }.not_to raise_error }
    context 'scheme is nil' do
      let(:url_string) { 'f6a.net' }
      it { expect { subject }.to raise_error(Gkhtmltopdf::URLSchemeInvalid, 'Invalid URL scheme: ()') }
    end
    context 'invalid scheme' do
      let(:url_string) { 'about://version' }
      it { expect { subject }.to raise_error(Gkhtmltopdf::URLSchemeInvalid, 'Invalid URL scheme: (about)') }
    end
  end
end
