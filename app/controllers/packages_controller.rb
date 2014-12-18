class PackagesController < ApplicationController
  def new
    package_details
    #response = Package.create(
    #  weight: params[:weight],
    #  width: params[:width],
    #  height: params[:height],
    #  length: params[:length]
    #)
    #response = hash (can do hash of params)
    #respond_to do |format|
    #  format.json {render json: response}
    #end
  end

  def thing
    #sends request with stuff
    #response = classwhttparty.post(
    #  'http://localhost:3000/package/new', :body => 
    #  {:weight => '3', :length => '3', :height => '3', :width => '3'})
    # this does a lot, it calls the thing posts something and then
    # it gets data back (see the other method that's ready with the response)
  end
  
  def package_details
    package = Package.new(
      (params[:weight] * 16),
      [params[:length], params[:width], params[:height]],
      :units => :imperial
    )
    destination = Location.new(
      :country => 'US',
      :state => params[:state],
      :city => params[:city],
      :zip => params[:zip],
    )
    origin = Location.new(
      :country => 'US',
      :state => 'WA',
      :city => 'Seattle',
      :zip => '98109',
    )   
    usps = USPS.new(:login => ENV['USPS_ACCESS_KEY'])
    usps_response = usps.find_rates(origin, destination, package)
    ups = UPS.new(
      :login => 'auntjudy',
      :password => 'secret',
      :key => ENV['UPS_ACCESS_KEY']
    ) 
    ups_response = ups.find_rates(origin, destination, package)
    usps_rates = usps_response.rates.sort_by(&:price).collect {
      |rate| [rate.service_name, rate.price]}
    ups_rates = ups_response.rates.sort_by(&:price).collect {
      |rate| [rate.service_name, rate.price]}
    response = ups_rates + usps_rates
    respond_to do |format|
      format.json {render json: response}
    end
  end
end
