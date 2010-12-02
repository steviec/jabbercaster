require 'rubygems'
require 'logger'
require 'yaml'
require 'eventmachine'
require 'jabbercaster/jabber_connection'
require 'xmpp4r'
require 'jabbercaster/patches/rexml_patch.rb'
require 'jabbercaster/gappsprovisioning/provisioningapi'

class Jabbercaster
  include GAppsProvisioning

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
    #Jabber.logger = self.logger
    #Jabber.debug = true
    google_apps_client = gdata_client(self.config['admin_user'], self.config['admin_password'])

    # lritter 2010-12-02 10:14:28:  Don't really *need* this call, but it prevents us
    # from trying to syndicate to group that doesn't exist
    groups_to_syndicate = fetch_filtered_groups(config['syndication_groups'].keys, google_apps_client)

    self.connections = create_group_connections(groups_to_syndicate, config['syndication_groups'], google_apps_client)

  end

  def create_group_connections(groups, group_configs, client)
    conns = []
    groups.each do |group|
      group_id = group.group_id
      group_config =  group_configs[group_id]
      except = group_config['except'] || []
      account_config = {
        "email" => transform_group_id(group_id),
        "password" => group_config['password'],
        "addresses" => get_group_members(group_id, client).map { |m| m.member_id }.reject { |m| except.include?(m) }
      }
      self.logger.info{ "Initializing #{group_id} jabber broadcast"}
      conns << JabberConnection.new(account_config, self.logger)
    end
    conns
  end

  def get_group_members(group_id, client)
    client.retrieve_all_members(group_id)
  end

  def transform_group_id(group_id)
    if group_id =~ /@animoto\.com$/
      elements = group_id.split('@')
      group_id = elements.first + "@" + "jabber." + elements.last
    end

    group_id
  end

  def gdata_client(admin_user, password, force=false)
    unless @client || force
      @client = ProvisioningApi.new(admin_user,password)
    end

    @client
  end

  def fetch_filtered_groups(group_names, client)
    logger.debug "Fetching group list"
    raw_group_list = client.retrieve_all_groups
    #logger.debug "Raw group list: #{raw_group_list.inspect}"
    raw_group_list.select { |g| group_names.include?(g.group_id) }
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
