require 'rubygems'
require 'logger'
require 'yaml'
require 'eventmachine'
require 'jabbercaster/jabber_connection'
require 'xmpp4r'
require 'jabbercaster/rexml_patch.rb'

class Jabbercaster

  attr_accessor :config
  attr_accessor :logger
  attr_accessor :connections

  def initialize(config_path_or_hash)
    @connections = []

    if(config_path_or_hash.is_a?(String))
      @config = YAML.load_file(File.expand_path(config_path_or_hash))
    elsif(config_path_or_hash.kind_of?(Hash))
      @config = config_path_or_hash 
    else
      raise ArgumentError, "configuration must be a path to a yaml config file or a config hash"
    end

    @logger = Logger.new( config['logfile'] || STDOUT)
    Jabber.logger = self.logger
    Jabber.debug = true

    # initialize jabber connection for each account
    config['accounts'].each do |account, account_config|
      logger.info{ "Initializing #{account} jabber broadcast"}
      self.connections << JabberConnection.new(account_config, logger)
    end
  end
  
  # start forwarding messages
  def start
    EM.run do
      EM::PeriodicTimer.new( config['polling_delay'] || 2) do
        connections.each do |conn|
          conn.process_messages
        end
      end
    end

  rescue Exception => e
    logger.info {"#{e.message} (#{e.class.name})\n" + e.backtrace().join("\n") + "\n"}
  end
  
end
