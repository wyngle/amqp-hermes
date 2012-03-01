require 'spec_helper'

describe AMQP::Hermes::Transmitter do
  before :each do
    @transmitter = AMQP::Hermes::Transmitter.new("test.queue.test")
    @receiver   = AMQP::Hermes::Receiver.new("test.queue")

    AMQP::Hermes.wait_for(@receiver, :listening?)
    @receiver.clear
  end

  after :each do
    @receiver.close
    @transmitter.close
  end

  it "should include connectivity" do
    @transmitter.should be_kind_of(AMQP::Hermes::Connectivity)
  end

  it "should hold a default queue" do
    @transmitter.queue.should == "test.queue.test"
  end

  it "should transmitt messages on the default queue" do
    message = Faker::Lorem.sentence
    @transmitter.transmit message

    AMQP::Hermes.wait_for(@receiver.messages, :any?)

    @receiver.messages.collect(&:payload).should include(message)
  end

  it "should transmitt messages on a given queue" do
    message = Faker::Lorem.sentence
    @transmitter.transmit(message, :routing_key => "test.queue.given")

    AMQP::Hermes.wait_for(@receiver.messages, :any?)

    @receiver.messages.collect(&:payload).should include(message)
    @receiver.messages.collect(&:headers).collect(&:routing_key).should include("test.queue.given")
  end

  it "should accept AMQP options" do
    message = Faker::Lorem.sentence
    @transmitter.transmit(message, :mandatory => true, :persistent => true)

    AMQP::Hermes.wait_for(@receiver.messages, :any?)

    @receiver.messages.collect(&:payload).should include(message)
  end

  it "should let know it's done transmitting" do
    message = Faker::Lorem.paragraph
    @transmitter.transmit(message, :mandatory => true, :persistent => true)
    @transmitter.should_not be_done_transmitting
  end
end
