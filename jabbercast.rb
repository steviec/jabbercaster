require 'rubygems'
require 'xmpp4r-simple'

# TODO:
# -event machine based system
# -broadcast auth requests to all parties
# -async accept requests and add to broadcast list
# -rescue in case of error and show "offline" to alert to problems
# -send messages to offline people?  no, allows dan/whoever to ignore when working from home
# -checkout group chat possiblities (msg.type == :groupchat)

# email accounts:
# animoto.techteam
# animoto.office

class Jabbercaster

  def initialize(email, password)
    @im = Jabber::Simple.new(email, password)
    @authorized_targets = []
  end
  
  # start forwarding messages
  def start
    return "Could not connect to jabber server" unless @im.connected?
    @im.accept_subscriptions = true
    request_authorizations

    while true
      @im.new_subscriptions do |account|
        @authorized_targets << account
      end
      
      # forward all messages received
      @im.received_messages do |msg|
        email = msg.from.to_s[/(.*)\//, 1] #everything before the "/"
        nickname = email[/(.*)\@/,1]   #everything before the "@"

        # don't send message back to sender
        targets.reject{|t| t == email}.each do |account|
          if msg.type == :chat
            @im.deliver(account, "[#{nickname}] #{msg.body}")
          end
        end
      end
      sleep 2
    end
  rescue Exception => e
    puts e.inspect
    @im.disconnect
  end
  
  # TODO: use gdata api to pull google apps list of accounts
  def targets
    %w(stevie@slowbicycle.com tclifton@gmail.com jeb1138@gmail.com dmag.animoto@gmail.com)
  end
  
  # add to event loop
  def request_authorizations
    @authorized_targets, pending_targets = targets.partition{ |t| @im.subscribed_to?(t) }
    pending_targets.each{ |t| @im.add(t) }
  end
end

email = 'animoto.techteam@gmail.com'
password = 'yourbull1'
jab = Jabbercaster.new(email, password)
jab.start
