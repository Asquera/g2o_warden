require 'warden'
require 'digest/hmac'
require 'digest/md5'

class Warden::Strategies::G2O < Warden::Strategies::Base
  
  def valid?
    if ["HTTP_X_AKAMAI_G2O_AUTH_DATA", "HTTP_X_AKAMAI_G2O_AUTH_SIGN"].all? { |header| !env[header.to_s].nil? }
      custom!([400, {"Content-Length" => "0"}, ["G2O Versions other than 3 are unsupported"]]) unless 3 == auth_data[:version].to_i
      true
    else
      false      
    end
  end

  def authenticate!
    given = env["HTTP_X_AKAMAI_G2O_AUTH_SIGN"]
    sign_data = "#{env["HTTP_X_AKAMAI_G2O_AUTH_DATA"]}#{request.path}" # even though the akamai documentation always specifically mentions "URL" they actually mean "PATH" *sigh*
    expected = Digest::HMAC.new(secret, Digest::MD5).base64digest(sign_data)
    
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
    env["HTTP_X_AKAMAI_G2O_AUTH_DATA"].split(",").each_with_index {|value, index|
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
