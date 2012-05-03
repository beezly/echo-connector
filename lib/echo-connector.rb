require "oauth"
require "nokogiri"
require 'nori'

module Echo360

class Echo360
  
  # Create an instance of the Echo360 interface
  #
  # ==== Attributes
  # * +site+ - Echo360 server URI (no default)
  # * +consumer_key+ - OAUTH Consumer Key (no default)
  # * +consumer_secret+ - OAUTH Consumer Secret (no default)
  # * +organisation+ - Organization to use (defaults to 0)  
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
    as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/campuses/").body)["campuses"]["campus"]
  end
  
  def get_campus campus_id
    Nori.parse(@access_token.get("/ess/scheduleapi/v1/campuses/#{campus_id}").body)["campus"]
  end
  
  def get_buildings arg = {}
    if arg.has_key? :campus
      as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/campuses/#{arg[:campus]}/buildings").body)["buildings"]["building"]
    else
      as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/buildings").body)["buildings"]["building"]
    end
  end
  
  def get_building building_id
    Nori.parse(@access_token.get("/ess/scheduleapi/v1/buildings/#{building_id}").body)["building"]
  end
  
  def get_rooms arg = {}
    if arg.has_key? :building
      as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/buildings/#{arg[:building]}/rooms").body)["rooms"]["room"]
    elsif arg.has_key? :campus
      as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/campuses/#{arg[:campus]}/rooms").body)["rooms"]["room"]
    else
      as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/rooms").body)["rooms"]["room"]
    end
  end
  
  def get_room room_id
    Nori.parse(@access_token.get("/ess/scheduleapi/v1/rooms/#{room_id}").body)["room"]
  end
  
  def get_users
    as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/people").body)["people"]["person"]
  end
  
  def get_terms 
    as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/terms").body)["terms"]["term"]
  end
  
  def get_term term_id
    Nori.parse(@access_token.get("/ess/scheduleapi/v1/terms/#{term_id}").body)["term"]
  end
  
  def get_courses arg = {}
    if arg.has_key? :term_id
      as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/terms/#{arg[:term_id]}/courses").body)["courses"]["course"]
    else
      as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/courses").body)["courses"]["course"]
    end
  end
  
  def get_course course_id
    Nori.parse(@access_token.get("/ess/scheduleapi/v1/courses/#{course_id}").body)["course"]
  end
  
  def get_sections arg = {}
    if (arg.has_key?(:term_id) && arg.has_key?(:course_id))
      as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/terms/#{arg[:term_id]}/courses/#{arg[:course_id]}/sections").body)["sections"]["section"]
    else
      if arg.has_key? :course_id
        as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/courses/#{arg[:course_id]}/sections").body)["sections"]["section"]
      elsif arg.has_key? :term_id
        as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/terms/#{arg[:term_id]}/sections").body)["sections"]["section"]
      else
        as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/sections").body)["sections"]["section"]
      end
    end
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
    as_array Nori.parse(@access_token.get("/ess/scheduleapi/v1/organizations").body)['organizations']['organization']
  end
  
  private
  def as_array item
    if item.class == Array
      item
    else
      [item]
    end
  end
end

end
