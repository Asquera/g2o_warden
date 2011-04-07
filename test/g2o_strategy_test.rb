require 'g2o_strategy'
require 'rack/builder'

context "G2O" do
  app(
    Rack::Builder.new do
      use Rack::Session::Cookie
      use Warden::Manager do |manager|
        manager.failure_app = -> env { [401, {"Content-Length" => "0"}, [""]] }
        manager.default_scope = :default
        manager.scope_defaults :default, :strategies => [:password, :basic]
        manager.scope_defaults :g2o, :strategies => [:g2o], 
                                       :store => false, 
                                       :g2o => { 
                                         :secret => "abcdefg",
                                       }
      end
      
      run -> env {
        env["warden"].authenticate!(:scope => :g2o)
        [200, {"Content-Length" => "0"}, [""]]
      }
    end.to_app
  ) 

  context "valid request" do
    setup do
      uri = "http://example.org/moavie.mp4"
      headers = {
        "X-Akamai-G2O-Auth-Data" => "3, 192.168.0.1, 192.168.1.1, 1302112359, 123, token",
        "X-Akamai-G2O-Auth-Sign" => "FDFur7kM8eCTi02yRz1yYw=="
      }
      get uri, {}, headers
    end

    asserts(:status).equals(200)
  end
  
  context "unsigned request" do
    setup do
      uri = "http://example.org/moavie.mp4"
      headers = {
        "X-Akamai-G2O-Auth-Data" => "3, 192.168.0.1, 192.168.1.1, 1302112359, 123, token",
      }
      get uri, {}, headers
    end

    asserts(:status).equals(401)
  end
  
  context "request without headers" do
    setup do
      uri = "http://example.org/moavie.mp4"
      headers = {
      }
      get uri, {}, headers
    end

    asserts(:status).equals(401)
  end
  
  context "request with crippled headers" do
    setup do
      uri = "http://example.org/moavie.mp4"
      headers = {
        "X-Akamai-G2O-Auth-Data" => "192.168.0.1, 192.168.1.1, 1302112359, 123, token",
      }
      get uri, {}, headers
    end

    asserts(:status).equals(401)
  end
  
  context "request with invalid signature" do
    setup do
      uri = "http://example.org/moavie.mp4"
      headers = {
        "X-Akamai-G2O-Auth-Data" => "3, 192.168.0.1, 192.168.1.1, 1302112359, 123, token",
        "X-Akamai-G2O-Auth-Sign" => "Asd456kM8eCTi02yRz1yYA=="
      }
      get uri, {}, headers
    end

    asserts(:status).equals(401)
  end
  
  context "valid request with unsupported version" do
    setup do
      uri = "http://example.org/moavie.mp4"
      headers = {
        "X-Akamai-G2O-Auth-Data" => "2, 192.168.0.1, 192.168.1.1, 1302112359, 123, token",
        "X-Akamai-G2O-Auth-Sign" => "FDFur7kM8eCTi02yRz1yYw=="
      }
      get uri, {}, headers
    end

    asserts(:status).equals(400)
  end
end
