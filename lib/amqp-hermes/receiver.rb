module AMQP
module Hermes
  class Receiver
    include AMQP::Hermes::Connectivity

    attr_reader :messages, :queue, :exchange, :routing_key
    attr_accessor :_listening

    def initialize(queue, topic="pub/sub", options={})
      raise "You *MUST* specify a queue" if queue.nil? or queue.empty?
      @queue = queue

      if topic.is_a? Hash
        options = topic.dup
        topic = options.delete(:topic) || "pub/sub"
      end

      @routing_key = options.delete(:routing_key)
      @routing_key ||= "#{queue}.*"

      if @routing_key !~ Regexp.new(queue)
        @routing_key = "#{queue}.routing_key"
      end

      @handler = options.delete(:handler) || self

      options[:auto_delete] ||= true
      @exchange = channel.topic(topic, options)

      @messages = []
      @_listening = false

      self.open_connection
      self.listen
    end

    def listen
      Thread.new(self, @handler) do |receiver, handler|
        receiver._listening = true

        receiver.channel.queue(receiver.queue).bind(
          receiver.exchange, :routing_key => receiver.routing_key
        ).subscribe do |headers, payload|
          handler.receive(AMQP::Hermes::Message.new(headers, payload))
        end
      end
    end

    def listening?
      @_listening == true ? true : false
    end

    # implement the handler interface
    def receive(message)
      return nil if !message.kind_of?(AMQP::Hermes::Message)
      @messages << message
    end

    def clear
      @messages = []
    end

    def inspect
      %Q{#<Hermes::Receiver @queue="#{@queue}" @routing_key="#{@routing_key}" @exchange="#{@exchange}" open=#{self.open?} listening=#{self.listening?}>}
    end
  end
end
end
