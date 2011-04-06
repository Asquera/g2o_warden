require 'warden'
require 'base64'

class Warden::Strategies::G2O < Warden::Strategies::Base
  
  def valid?
    ["X-Akamai-G2O-Auth-Data", "X-Akamai-G2O-Auth-Sign"].all? { |header| !env[header.to_s].nil? } && 3 == auth_data[:version].to_i
  end

  def authenticate!
    given = env["X-Akamai-G2O-Auth-Sign"]
    sign_data = "#{env["X-Akamai-G2O-Auth-Data"]}#{request.url}"
    expected = Base64.encode64(OpenSSL::HMAC.digest("md5", secret, sign_data)).chomp # for whatever reason base64 encode adds a newline
    
    if given == expected
      success!(retrieve_user)
    else
      halt!
    end
  end
  
  def auth_data
    index_map = {
      0 => :version,
      1 => :ghost_ip,
      2 => :client_ip,
      3 => :timestamp,
      4 => :uniqid,
      5 => :nonce
    }
    
    data = {}
    env["X-Akamai-G2O-Auth-Data"].split(",").each_with_index {|value, index|
      data[index_map[index.to_i]] = value.strip
    }
    data
  end
  
  def retrieve_user
    true
  end
  
  private
    def config
      env["warden"].config[:scope_defaults][scope][:g2o]
    end
    
    def secret
      config[:secret]
    end
end

Warden::Strategies.add(:g2o, Warden::Strategies::G2O)
