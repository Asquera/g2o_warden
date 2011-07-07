require 'warden'
require 'digest/hmac'
require 'digest/md5'


# Warden strategy that implements a type 3 (HMAC) Akamai G2O Authentication
# Type 1 and type 2 authentication is not supported.
#
# @author Felix Gilcher <felix.gilcher@asquera.de>
#
class Warden::Strategies::G2O < Warden::Strategies::Base
  
  
  # Checks that this strategy applies. Tests that the required
  # authentication type was given and returns a 400 Invalid Request error
  # if not.
  #
  # @return [Bool] true if all required authentication information is available in the request
  # @see https://github.com/hassox/warden/wiki/Strategies
  def valid?
    if ["HTTP_X_AKAMAI_G2O_AUTH_DATA", "HTTP_X_AKAMAI_G2O_AUTH_SIGN"].all? { |header| !env[header.to_s].nil? }
      custom!([400, {"Content-Length" => "0"}, ["G2O Versions other than 3 are unsupported"]]) unless 3 == auth_data[:version].to_i
      true
    else
      false      
    end
  end

  # Performs authentication. Calls success! if authentication was performed successfully and halt!
  # if the authentication information is invalid
  #
  # @see https://github.com/hassox/warden/wiki/Strategies  
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
  
  # Provides access to the authentication data in the request. The result contains
  # the following information:
  #
  # * :version The g2o version in the request
  # * :ghost_ip The IP of the akamai edge server requesting the file
  # * :client_ip The IP of the client connected to the akamai edge server (ghost)
  # * :timestamp The timestamp of the request as seen by the edge server (ghost)
  # * :uniqid A unique id given to the request by the ghost
  # * :nonce This parameters is named "nonce" since Akamai calls it a nonce. It's more of a key identifier.
  #
  # @return [Hash] a hash containing the authentication data.
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
  
  # overwrite this method to retrieve a user object from any kind
  # of storage. You'll probably never need this in this context. Called
  # by authenticate! on authentication success.
  #
  # @see https://github.com/hassox/warden/wiki/Strategies
  def retrieve_user
    true
  end
  
  private
  
    # provides access to the :g2o configuration key in the current warden scope
    #
    # @return [Hash] the configuration options as set in the warden config
    def config
      env["warden"].config[:scope_defaults][scope][:g2o]
    end
    
    def secret
      config[:secret]
    end
end

Warden::Strategies.add(:g2o, Warden::Strategies::G2O)
