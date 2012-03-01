require 'spec_helper'

describe AMQP::Hermes::Connectivity do
  before :each do
    @subject = Class.new
    @subject.extend(AMQP::Hermes::Connectivity)
  end

  after :each do
    @subject.close
  end

  it "should have an open connection" do
    @subject.connection.should_not be_nil
    @subject.should be_open
    @subject.connection.should be_kind_of(AMQP::Session)
  end

  it "should have an open channel" do
    @subject.channel.should_not be_nil
    @subject.channel.should be_kind_of(AMQP::Channel)
  end

  it "should close" do
    @subject.open_connection
    @subject.should be_open

    @subject.close

    @subject.should_not be_open
  end
end

