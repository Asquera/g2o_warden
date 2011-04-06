# HMAC

This gem provides a warden strategy that validates type 3 G2O requests for use with the Akamai G2O implementation.

    
## Warden strategy usage

Configure the G2O warden strategy:

    use Warden::Manager do |manager|
      manager.failure_app = -> env { [401, {"Content-Length" => "0"}, [""]] }
      # other scopes
      manager.scope_defaults :g2o, :strategies => [:g2o], 
                                     :store => false, 
                                     :g2o => { 
                                       :secret => "secrit",
                                     }
    end

`secret` allows you to specify the secret used for the HMAC algorithm. 