require 'spec_helper'
require 'gkhtmltopdf'

RSpec.describe Gkhtmltopdf::Converter do
  let(:converter) { Gkhtmltopdf::Converter.allocate }
  describe '#resolve_geckodriver_path!' do
    subject { converter.send(:resolve_geckodriver_path!, nil) }
    context 'geckodriver is not available' do
      before { allow(File).to receive(:executable?).and_return(false) }
      it 'raises an error' do
        expect { subject }.to raise_error(Gkhtmltopdf::Error, /\AGeckodriver is not found./)
      end
    end
  end

  describe '#resolve_firefox_path!' do
    subject { converter.send(:resolve_firefox_path!, nil) }
    context 'firefox is not available' do
      before { allow(File).to receive(:executable?).and_return(false) }
      it 'raises an error' do
        expect { subject }.to raise_error(Gkhtmltopdf::Error, /\AFirefox is not found./)
      end
    end
  end
  describe '#wait_for_server' do
    subject { converter.send(:wait_for_server) }
    context 'fail launch geckodriver' do
      before { allow(Net::HTTP).to receive(:get).and_raise(Errno::ECONNREFUSED, 'Dummy error') }
      it 'raises an error' do
        expect { subject }.to raise_error(Gkhtmltopdf::Error, /\AFailed to launch geckodriver \(port \)\Z/)
      end
    end
  end
  describe '#post' do
    let(:converter) { Gkhtmltopdf::Converter.new }
    subject { converter.send(:post, '/dummy', {test: :value}) }
    context 'Invalid json response from geckodriver' do
      before {
        allow(Net::HTTP).to receive(:start).and_return(Struct.new(:code, :body).new('200', 'invalid_json: 0123'))
      }
      it 'raises an error' do
        expect { subject }.to raise_error(Gkhtmltopdf::Error, 'Invalid geckodriver response (Status: 200): invalid_json: 0123')
      end
    end
  end
end
