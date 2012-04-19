require "oauth"
require "nokogiri"

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
    @organisation = getOrganizations[organisation][:id]
  end

  def get_users
    users_xml = get_users_xml
    users = Array.new
    users_xml.xpath("/people/person").each do |person|
      id = person.search('id')[0].content 
      first_name = person.search('first-name')[0].content
      last_name = person.search('last-name')[0].content
      user_id = person.search('user-name')[0].content
      users << { id: id, first_name: first_name, last_name: last_name, user_id: user_id }
    end
    users
  end

  def get_user user_id
    users_xml = get_users_xml
    person = users_xml.xpath("/people/person[user-name/text() = \"#{user_id}\"]")[0]
    raise "User not found: #{user_id}" if person.nil?
    id = person.search('id')[0].content
    first_name = person.search('first-name')[0].content
    last_name = person.search('last-name')[0].content
    user_id = person.search('user-name')[0].content
    { id: id, first_name: first_name, last_name: last_name, user_id: user_id }
  end
  
  def createUser user_id, password, first_name, last_name, role, email
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
  
  private
  
  def get_users_xml
    Nokogiri.XML @access_token.get("/ess/scheduleapi/v1/people").body
  end
  
  def getOrganizations
    response = @access_token.get "/ess/scheduleapi/v1/organizations"
    org_xml = Nokogiri.XML response.body

    orgs = Array.new

    org_xml.search('organization').each do |org|
      id = org.search('id')[0].content
      name = org.search('name')[0].content
      orgs << { name: name, id: id }
    end

    orgs
  end
end

end
