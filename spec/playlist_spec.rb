require 'spec_helper'

describe ZendeskAPI::Playlist do
  subject { ZendeskAPI::Playlist }

  before(:each) do
    stub_request(:get, %r{views/\d+/play}).to_return(:status => 302, :body => "You are being redirected...")
  end

  it "should begin playing the playlist on initialization" do
    subject.new(client, 1)
  end

  context "#next" do
    subject { ZendeskAPI::Playlist.new(client, 1) }

    before(:each) do
      stub_json_request(:get, %r{play/next}, json("ticket" => {}))
    end

    it "should return ticket" do
      subject.next.should be_instance_of(ZendeskAPI::Ticket)
    end

    context "with client error", :silence_logger do
      before(:each) do
        stub_request(:get, %r{play/next}).to_return(:status => 500)
      end

      it "should be raised" do
        expect { subject.next.should be_nil }.to raise_error
      end
    end

    context "with end of playlist" do
      before(:each) do
        stub_request(:get, %r{play/next}).to_return(:status => 204)
      end

      it "should be properly handled" do
        subject.next.should be_nil
        subject.destroyed?.should be_true
      end
    end
  end

  context "#destroy" do
    subject { ZendeskAPI::Playlist.new(client, 1) }

    before(:each) do
      stub_request(:delete, %r{play}).to_return(:status => 204)
    end

    it "should be destroyed" do
      subject.destroy.should be_true
      subject.destroyed?.should be_true
    end

    context "with client error", :silence_logger do
      before(:each) do
        stub_request(:delete, %r{play}).to_return(:status => 500)
      end

      it "should be raised" do
        expect { subject.destroy.should be_false }.to raise_error
      end
    end
  end

  context "initialization" do
    context "with client error", :silence_logger do
      before(:each) do
        stub_request(:get, %r{views/\d+/play}).to_return(:status => 500).to_return(:status => 302)
        stub_request(:get, %r{play/next}).to_return(:body => json)
      end

      it "should not be able to be created" do
        expect { subject.new(client, 1) }.to raise_error
      end
    end
  end
end
