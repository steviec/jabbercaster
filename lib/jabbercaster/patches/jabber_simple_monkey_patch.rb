require 'xmpp4r-simple'

module JabberSimpleMonkeyPatches
#def initialize(jid, password, status = nil, status_message = "Available")
  def initialize(*args, &block)
    yield self if block_given?
    super(*args)
  end
end

module Jabber
  class Simple
    #include JabberSimpleMonkeyPatches
    #puts "hi"
    alias_method :old_initialize, :initialize
    def initialize(jid, password, status = nil, status_message = "Available")
      @host = "talk.google.com"
      old_initialize(jid, password, status, status_message)
    end

    def connect!
      raise ConnectionError, "Connections are disabled - use Jabber::Simple::force_connect() to reconnect." if @disconnected
      # Pre-connect
      @connect_mutex ||= Mutex.new

      # don't try to connect if another thread is already connecting.
      return if @connect_mutex.locked?

      @connect_mutex.lock
      disconnect!(false) if connected?

      # Connect
      jid = JID.new(@jid)
      my_client = Client.new(@jid)
      my_client.connect @host
      
      #('talk.google.com')
      my_client.auth(@password)
      self.client = my_client

      # Post-connect
      register_default_callbacks
      status(@presence, @status_message)
      @connect_mutex.unlock
    end
  end
end
