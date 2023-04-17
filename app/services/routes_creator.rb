require 'dotenv'
require 'json'

class RoutesService
  def self.index(origin, destination)
    routes = Route.select([:id, :routeSummary, :totalTravelTime, :travelMode, :totalTravelDistance])
                  .where(origin: origin, destination: destination)
    { success: true, data: routes }
  rescue => e
    { success: false, error: e.message }
  end

  def self.show(id)
    route = Route.find(id)
    { success: true, data: route }
  rescue => e
    { success: false, error: e.message }
  end

  def self.create(start, finish, location_id)
    response = RestClient.get "#{ENV["GOOGLE_DIRECTIONS_API"]}?origin=#{start}&destination=#{finish}&key=#{ENV["GOOGLE_API_KEY"]}"
    parsed_response = JSON.parse(response.body)
    
    if parsed_response["status"] == "REQUEST_DENIED"
      return { success: false, error: "Something went wrong" }
    end

    routes_created = []
    parsed_response["routes"].each do |route|
      temp = Route.create(
        origin: start,
        destination: finish,
        routeSummary: route["summary"],
        data: route.to_json,
        location_id: location_id,
        totalTravelTime: route["legs"][0]["duration"]["text"],
        travelMode: route["legs"][0]["steps"][0]["travel_mode"],
        totalTravelDistance: route["legs"][0]["distance"]["text"]
      )
      temp.save
      routes_created << temp
    end

    { success: true, data: routes_created }
  rescue => e
    { success: false, error: e.message }
  end

  def self.update(start, finish, location_id)
    Route.where(origin: start, destination: finish).destroy_all()
    create(start, finish, location_id)
  end

  def self.destroy(id)
    route = Route.find(id)
    route.destroy
    { success: true, message: "#{id} has been deleted!" }
  rescue => e
    { success: false, error: e.message }
  end
end
