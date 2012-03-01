require 'amqp'

require "amqp-hermes/version"
require 'amqp-hermes/connectivity'
require 'amqp-hermes/transmitter'
require 'amqp-hermes/receiver'
require 'amqp-hermes/message'

module AMQP
module Hermes
  def self.wait_for(something, test, max=50)
    res = something.send(test)
    unless [ true, false ].include?(res)
      raise "Can only wait for true or false"
    end
    return 0 if res == true

    wait_count = 0
    while !something.send(test)
      raise "Waited long enough" if ( wait_count += 1 ) > max
      sleep 0.1
    end

    return wait_count
  end
end
end
