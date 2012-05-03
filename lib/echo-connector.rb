require "oauth"
require "nokogiri"
require 'nori'

module Echo360

class Echo360
  def initialize(site, consumer_key, consumer_secret, organisation = 0)
    consumer = OAuth::Consumer.new consumer_key, consumer_secret, 
                { :site => site,
                  :request_token_path => "",
                  :authorize_path => "",
                  :access_token_path => "",
                  :http_method => :get }
  
    @access_token = OAuth::AccessToken.new consumer
    @organisation = get_organizations[organisation]["id"]
  end

  def get_campuses term = nil
    Nori.parse(@access_token.get("/ess/scheduleapi/v1/campuses/").body)["campuses"]["campus"]
  end
  
  def get_campus campus_id
    Nori.parse(@access_token.get("/ess/scheduleapi/v1/campuses/#{campus_id}").body)["campus"]
  end
  
  def get_buildings arg = {}
    if arg.has_key? :campus
      Nori.parse(@access_token.get("/ess/scheduleapi/v1/campuses/#{arg[:campus]}/buildings").body)["buildings"]["building"]
    else
      Nori.parse(@access_token.get("/ess/scheduleapi/v1/buildings").body)["buildings"]["building"]
    end
  end
  
  def get_building building_id
    Nori.parse(@access_token.get("/ess/scheduleapi/v1/buildings/#{building_id}").body)["building"]
  end
  
  def get_rooms arg = {}
    if arg.has_key? :building
      Nori.parse(@access_token.get("/ess/scheduleapi/v1/buildings/#{arg[:building]}/rooms").body)["rooms"]["room"]
    elsif arg.has_key? :campus
      Nori.parse(@access_token.get("/ess/scheduleapi/v1/campuses/#{arg[:campus]}/rooms").body)["rooms"]["room"]
    else
      Nori.parse(@access_token.get("/ess/scheduleapi/v1/rooms").body)["rooms"]["room"]
    end
  end
  
  def get_room room_id
    Nori.parse(@access_token.get("/ess/scheduleapi/v1/rooms/#{room_id}").body)["room"]
  end
  
  def get_users
    Nori.parse(@access_token.get("/ess/scheduleapi/v1/people").body)["people"]["person"]
  end

  def get_user user_id
    users = get_users
    users.detect {|u| u["user_name"] == user_id }
  end
  
  def create_user user_id, password, first_name, last_name, role, email
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.person {
        xml.send(:"first-name", first_name)
        xml.send(:"last-name", last_name)
        xml.send(:"email-address", email)
        xml.role role
        xml.credentials {
          xml.send(:"user-name", user_id)
          xml.password password
        }
        xml.send(:"organization-roles") {
          xml.send(:"organization-role") {
            xml.send(:"organization-id", @organisation)
            xml.role role
          }
        }
      }
    end
    rsp = @access_token.post("/ess/scheduleapi/v1/people", builder.to_xml,{ 'Accept' => 'application/xml', 'Content-Type' => 'application/xml' })
    !rsp.value
  end
    
  def get_organizations
    Nori.parse(@access_token.get("/ess/scheduleapi/v1/organizations").body)["organizations"]["organization"]
  end
end

end
