module AMQP
module Hermes
  class Message
    attr_reader :headers, :payload

    def initialize(headers, payload)
      @headers = headers
      @payload = payload
    end
  end
end
end
