require 'spec_helper'

describe Superbolt::MessageRam do
  let(:error_class) { Exception }
  let(:messenger) { double(
    retry_time: 1,
    timeout: 5,
    live_queue: double('queue', close: true)
  )}
  let(:stdout) { StringIO.new('') }
  let(:ram) { Superbolt::MessageRam.new(messenger, :some_method, stdout) }

  before do
    messenger.should_receive(:some_method).ordered.and_raise('Some Error')
  end

  context "failed to open connection" do
    before do
      expect(messenger).to receive(:some_method)
        .ordered
        .and_return(true)
    end

    it 'should raise no errors' do
      expect {
        ram.besiege
      }.to_not raise_error
    end

    it "retries on a configured interval" do
      ram.besiege.should == true
    end

    it "reports the errors" do
      ram.besiege
      stdout.string.should match(/Something went wrong/)
    end
  end

  context 'it runs out of time' do
    before do
      ram.run_time = 6
    end

    it 'should raise error' do
      expect {
        ram.besiege
      }.to raise_error(Exception)
    end
  end
end