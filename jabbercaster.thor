require 'jabbercast.rb'

class Jabbercaster < Thor
  desc "start email password targets", "needs email, password, and targets"
  def start(email, password, group_email)
    jc = Jabbercast.new
    jc.start
  end
end
