class RoutesController < ApplicationController
  before_action :load_location, only: [:create, :update]

  def index
    result = RoutesService.index(params['origin'], params['destination'])
    if result[:success]
      render json: result[:data]
    else
      logger.error result[:error]
      render json: "Something went wrong"
    end
  end

  def show
    result = RoutesService.show(params[:id])
    if result[:success]
      render json: result[:data]
    else
      logger.error result[:error]
      render json: "Something went wrong"
    end
  end

  def create
    result = RoutesService.create(params["start"], params["end"], params["locationId"])
    if result[:success]
      render json: "Success"
    else
      logger.error result[:error]
      render json: "Something went wrong"
    end
  end

  def update
    result = RoutesService.update(params['start'], params['end'], params['locationId'])
    if result[:success]
      render json: "Success"
    else
      logger.error result[:error]
      render json: "Something went wrong"
    end
  end

  def destroy
    result = RoutesService.destroy(params[:id])
    if result[:success]
      render json: result[:message]
    else
      logger.error result[:error]
      render json: "Something went wrong"
    end
  end

  private

  def load_location
    @location = Location.find(params["locationId"])
    logger.info @location
  end
end
