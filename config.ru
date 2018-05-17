require 'omniauth-ldap'
require 'nginx_omniauth_adapter'
require 'yaml'

config = YAML.load_file(File.join(__dir__, 'config', "#{ENV['RACK_ENV'] || 'development'}.yml"))

use Rack::Session::Cookie,
    :key => config[:key],
    :secret => config[:secret],
    :secure => true
use OmniAuth::Strategies::LDAP, 
    :title => config[:title], 
    :host => config[:server],
    :port => config[:port] || 389,
    :method => config[:method] || :tls,
    :base => config[:base],
    :filter => config[:filter],
    :name_proc => Proc.new {|name| name.gsub(/@.*$/,'')},
    :bind_dn => 'default_bind_dn'

run NginxOmniauthAdapter.app(
  providers: %i(ldap),
  key: config[:key],
  secret: config[:secret],
  host: config[:auth_host],
  allowed_app_callback_url: config[:allow],
  app_refresh_interval: config[:app_refresh_interval] || 60 * 60 * 24 * 2,
  adapter_refresh_interval: config[:adapter_refresh_interval] || 60 * 60 * 24 * 7,
)
