require 'rubygems'
require 'xmpp4r-simple'

class JabberConnection
  attr_accessor :connection, :authorized_targets

  def initialize(config)
    email = config['email']
    password = config['password']
    @connection = Jabber::Simple.new(email, password)
    @authorized_targets = []
    @targets = config['addresses']
    
    return "Could not connect to jabber server" unless @connection.connected?
    @connection.accept_subscriptions = true
    request_authorizations
  end
  
  # check for any new messages and deliver
  def process_messages

    # if any accounts have authorized, add to forwarding list
    @connection.new_subscriptions do |account|
      @authorized_targets << account
    end

    # forward all messages received
    @connection.received_messages do |msg|
      email = msg.from.to_s[/(.*)\//, 1] #everything before the "/"
      nickname = email[/(.*)\@/,1]   #everything before the "@"

      # don't send message back to sender
      targets.reject{|t| t == email}.each do |account|
        if msg.type == :chat
          @connection.deliver(account, "[#{nickname}] #{msg.body}")
        end
      end
    end
    
  end
  
  # TODO: use gdata api to pull google apps list of accounts
  def targets
    @targets
  end
  
  def request_authorizations
    @authorized_targets, pending_targets = targets.partition{ |t| @connection.subscribed_to?(t) }
    pending_targets.each{ |t| @connection.add(t) }
  end
    
end