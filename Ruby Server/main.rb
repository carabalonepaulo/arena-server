require 'eventmachine'
require 'colorize'
require 'digest'

require './constants'

require './scripts/system/item_base'
require './scripts/system/armor'
require './scripts/system/item'
require './scripts/system/weapon'
require './scripts/system/game_system'

require './scripts/binary'
require './scripts/database'
require './scripts/logger'
require './scripts/server'
require './scripts/handler'
require './scripts/sender'
require './scripts/client'

EventMachine.run do
  Signal.trap('INT')  { EventMachine.stop; $logger.save if $logger }
  Signal.trap('TERM') { EventMachine.stop; $logger.save if $logger }

  $database = Database.new
  $logger = Logger.new
  $server = Server.new

  EventMachine.start_server('0.0.0.0', 5000, Client)
end