require 'dotenv'
require 'json'

class RoutesController < ApplicationController
  before_action :load_location, only: [:create, :update]

  def index
    @routes = Route.select([:id, :routeSummary, :totalTravelTime, :travelMode, :totalTravelDistance])
                  .where(origin: params['origin'], destination: params['destination'])
    render json: @routes
  rescue => err
    logger.error err
    render json: "Something went wrong"
  end

  def show
    @route = Route.find(params[:id])
    render json: @route
  rescue => err
    logger.error err
    render json: "Something went wrong"
  end

  def create
    @response = RestClient.get "#{ENV["GOOGLE_DIRECTIONS_API"]}?origin=#{params["start"]}&destination=#{params["end"]}&key=#{ENV["GOOGLE_API_KEY"]}"
    @parsedResponse = JSON.parse(@response.body)
    
    if @parsedResponse["status"] == "REQUEST_DENIED"
      logger.error @parsedResponse
      return render json: { errors: "Something went wrong" }, code: 403
    end

    @parsedResponse["routes"].each do |route|
      temp = Route.create(
        origin: params["start"],
        destination: params["end"],
        routeSummary: route["summary"],
        data: route.to_json,
        location: @location,
        totalTravelTime: route["legs"][0]["distance"]["text"],
        travelMode: route["legs"][0]["duration"]["text"],
        totalTravelDistance: route["legs"][0]["steps"][0]["travel_mode"]
      )
      temp.save
    end

    render json: "Success"
  rescue => e
    logger.error e.message
    logger.error e.backtrace.join("\n")
    render json: "Something went wrong"
  end

  def update
    Route.where(origin: params['start'], destination: params['end']).destroy_all()
    create
  end

  def destroy
    @route = Route.find(params[:id])
    @route.destroy
    render json: "#{params[:id]} has been deleted!"
  rescue => err
    logger.error err
    render json: "Something went wrong"
  end

  private

  def load_location
    @location = Location.find(params["locationId"])
    logger.info @location
  end
end
