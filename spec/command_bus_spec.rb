=begin
command_bus_spec.rb

Copyright 2015 Richard J. Turner <rjt@zygous.co.uk>

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

=end
require 'command_bus'
require 'rspec'

include Zygous::CommandBus

describe 'Command Bus' do
  it 'should dispatch the correct handler for a given command' do
    hello_handler   = double 'HelloCommandHandler', :call => true
    goodbye_handler = double 'GoodbyeCommandHandler', :call => true

    hello_command   = double 'HelloCommand', :name => :say_hello_command

    bus = Bus.new(
      :say_hello_command   => hello_handler,
      :say_goodbye_command => goodbye_handler
    )

    expect(hello_handler).to receive :call
    expect(goodbye_handler).not_to receive :call

    bus.handle hello_command
  end

  it 'should error when trying to dispatch a command without a registered handler' do
    hello_handler = double 'HelloCommandHandler', :call => true

    error_command = double 'ErrorCommand', :name => :cause_error_command

    bus = Bus.new :say_hello_command => hello_handler

    expect {bus.handle error_command}.to raise_error RuntimeError
  end

  it 'should allow more handlers to be registered after initialization' do
    hello_handler   = double 'HelloCommandHandler', :call => true
    goodbye_handler = double 'GoodbyeCommandHandler', :call => true

    hello_command   = double 'HelloCommand', :name => :say_hello_command

    bus = Bus.new(:say_goodbye_command => goodbye_handler)

    bus.add_handler :say_hello_command, hello_handler

    expect(hello_handler).to receive :call

    bus.handle hello_command
  end

  it 'should finish handling one command before handling the next' do
    log = []
    bus = Bus.new({})

    outer_command_handler = lambda do |command|
      log << "Start handling #{command.name}"

      nested_command = double 'NestedCommand', :name => :nested_command
      bus.handle nested_command

      log << "Finished handling #{command.name}"
    end

    nested_command_handler = lambda do |command|
      log << "Handled #{command.name}"
    end

    bus.add_handler :outer_command, outer_command_handler
    bus.add_handler :nested_command, nested_command_handler

    bus.handle(double 'OuterCommand', :name => :outer_command)

    expect(log).to eq [
      'Start handling outer_command',
      'Finished handling outer_command',
      'Handled nested_command'
    ]
  end
end
