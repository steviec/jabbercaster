Gem::Specification.new do |s|
  s.platform  = Gem::Platform::RUBY
  s.name      = "jabbercaster"
  s.version   = "0.0.2"
  s.summary   = "Chat broadcast"
  s.description = "Fake chatroom via rebroadcast of incomming messages"

  s.required_ruby_version = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.2"

  s.authors   = ['stevie@animoto.com', 'dan@animoto.com', 'lincoln@animoto.com']

  s.files         = Dir.glob("{bin,lib}/**/*") + %w(README.markdown)
  s.require_path  = 'lib'

  s.executables   = ['jabbercaster']

  s.add_dependency  'xmpp4r-simple'
  s.add_dependency  'eventmachine'
end
