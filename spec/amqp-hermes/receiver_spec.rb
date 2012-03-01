require 'spec_helper'

class CustomHandler
  def received?
    @received == true ? true : false
  end
  def receive(message)
    @received = true
  end
end

describe CustomHandler do
  it "should be a working alternate handler" do
    handler = CustomHandler.new
    handler.should_not be_received

    handler.receive(AMQP::Hermes::Message.new("crud", "crud"))
    handler.should be_received
  end
end

describe AMQP::Hermes::Receiver do
  before :each do
    @receiver = AMQP::Hermes::Receiver.new("test.queue")
    AMQP::Hermes.wait_for(@receiver, :listening?)
    @receiver.clear
  end

  after :each do
    @receiver.close
  end

  it "should include connectivity" do
    @receiver.should be_kind_of(AMQP::Hermes::Connectivity)
  end

  it "should set a default routing key" do
    @receiver.routing_key.should == "test.queue.*"
  end

  it "should set a default handler" do
    @receiver.instance_variable_get(:@handler).should == @receiver
  end

  it "should open an exchange" do
    @receiver.exchange.should_not be_nil
    @receiver.exchange.should be_kind_of(AMQP::Exchange)
  end

  it "should be listening" do
    @receiver.should be_listening
  end

  it "should implement a handler interface" do
    @receiver.messages.should be_empty
    transmitter = AMQP::Hermes::Transmitter.new("test.queue.test")
    transmitter.transmit "crud"

    AMQP::Hermes.wait_for(@receiver.messages, :any?)
    @receiver.messages.should be_any
  end

  it "should accept an alternate handler" do
    handler = CustomHandler.new

    @receiver.close
    @receiver = AMQP::Hermes::Receiver.new("test.queue", :handler => handler)

    @receiver.instance_variable_get(:@handler).should == handler

    AMQP::Hermes.wait_for(@receiver, :listening?)

    transmitter = AMQP::Hermes::Transmitter.new("test.queue.test")
    transmitter.transmit "crud"

    AMQP::Hermes.wait_for(handler, :received?)
  end
end
