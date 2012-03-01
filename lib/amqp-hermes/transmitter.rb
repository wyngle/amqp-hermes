module AMQP
module Hermes
  class Transmitter
    include AMQP::Hermes::Connectivity

    attr_reader :queue
    def initialize(queue=nil, topic="pub/sub", options={})
      @queue = queue

      options[:auto_delete] ||= true
      @exchange = channel.topic(topic, options)
      @transmitting = false
    end

    def transmit(payload, options={})
      @transmitting = true

      options.merge!(
        :routing_key => @queue
      ) unless options.has_key?(:routing_key)

      @exchange.publish( payload, options ) do
        @transmitting = false
      end
    end

    def done_transmitting?
      @transmitting == true ? false : true
    end

    def close
      AMQP::Hermes.wait_for(self, :done_transmitting?)
      super
    end
  end
end
end
