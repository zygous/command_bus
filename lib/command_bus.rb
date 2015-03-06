=begin
command_bus.rb

Copyright 2015 Richard J. Turner <rjt@zygous.co.uk>

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

=end
module Zygous
  module CommandBus

class Bus

  def initialize handlers
    @handlers = handlers
  end

  def add_handler command_name, handler
    @handlers[command_name] = handler
  end

  def handle command
    raise "Handler for command #{command.name} not registered." unless
        @handlers.has_key? command.name

    @queue ||= []
    @queue << command

    return if @currently_dispatching

    @currently_dispatching = true

    @queue.delete_if do |command|
      begin
        @handlers[command.name].call command
      rescue exception
        @currently_dispatching = false
        throw exception
      end
    end

    @currently_dispatching = false
  end

end

  end
end

