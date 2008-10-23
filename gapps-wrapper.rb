#!/usr/bin/ruby
require 'gappsprovisioning/provisioningapi'
include GAppsProvisioning
adminuser = "stevie@animoto.com"
password  = "airborne"
myapps = ProvisioningApi.new(adminuser,password)
puts myapps.retrieve_email_list('techteam@animoto.com')
