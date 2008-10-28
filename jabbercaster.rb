require 'rubygems'
require 'logger'
require 'yaml'
require 'eventmachine'
require 'jabber_connection'

class Jabbercaster

  def initialize
    @conns = []
    @config = YAML.load_file('./jabbercaster.yml')
    @logger = Logger.new( @config['logfile'] || STDOUT)

    # initialize jabber connection for each account
    @config['accounts'].each do |account, config|
      @logger.info{ "Initializing #{account} jabber broadcast"}
      @conns << JabberConnection.new(config)
    end
  end
  
  # start forwarding messages
  def start
    EM.run do
      EM::PeriodicTimer.new( @config['polling_delay'] || 2) do
        @conns.each do |conn|
          conn.process_messages
        end
      end
    end

  rescue Exception => e
    @logger.info {"#{e.message} (#{e.class.name})\n" + e.backtrace().join("\n") + "\n"}
  end
  
end