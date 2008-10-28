require 'jabbercast'

class Jabbercaster < Thor
  desc "start email password targets", "needs email, password, and targets"
  def start
    jc = Jabbercast.new
    jc.start
  end
end
