module AMQP
module Hermes
  module Connectivity
    def connection
      @connection || open_connection
    end

    def open_connection
      return @connection if self.open?

      # start a ractor if non running
      unless EventMachine.reactor_running?
        Thread.new do
          EventMachine.run
        end

        AMQP::Hermes.wait_for(EventMachine, :reactor_running?)
      end

      @connection = AMQP.connect
    end

    def open?
      EventMachine.reactor_running? && !@connection.nil?
    end

    def channel
      @channel || open_channel
    end

    def open_channel
      @channel = AMQP::Channel.new(self.connection)
    end

    def close
      return if !open?

      @connection.close

      AMQP.stop do
        EventMachine.stop
      end

      @connection = nil
    end
  end
end
end
