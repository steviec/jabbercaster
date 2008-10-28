require 'rubygems'
require 'logger'
require 'eventmachine'
require 'jabber_connection'

class Jabbercast

  def initialize
    @conns = []
    @config = YAML.load_file('./jabbercast.yml')
    @config['accounts'].each{ |account, config| @conns << JabberConnection.new(config) }
    @logger = Logger.new( @config['logfile'] || STDOUT)
  end
  
  # start forwarding messages
  def start
    @logger.info { "Starting jabber broadcasts for: #{@config['accounts'].keys.inspect}"}
    EM.run do
      EM::PeriodicTimer.new( @config['polling_delay'] || 2) do
        @conns.each do |conn|
          conn.process_messages
        end
      end
    end

  rescue Exception => e
    @logger.info{"#{e.message} (#{e.class.name})\n" + e.backtrace().join("\n") + "\n"} if @logger
  end
  
end

jc = Jabbercast.new
jc.start