# Jabbercaster

This class allows you to broadcast jabber messages to a list of contacts.  You can get the same (or better) functionality by just using a groupchat, but most jabber clients don't support a permanent groupchat, so this allows you to send a message to a contact that will forward the message to all contacts in your yml config.  Sample messages include "deploying new codebase to production servers" or "who the hell is taking all the bandwidth?!?"

## Required gems

 * [eventmachine](http://rubyeventmachine.com/)
 * [xmpp4r-simple](http://github.com/blaine/xmppr4-simple/)

## Executing

Run "rake jabbercaster:start &" for background execution.

## TODO

 * Add tests
 * Allow dynamic authorized users by grabbing the contact list from server

