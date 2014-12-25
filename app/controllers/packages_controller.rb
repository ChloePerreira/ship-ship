class PackagesController < ApplicationController
require 'active_shipping'
include ActiveMerchant::Shipping

  def new
    if params[:state].empty? || params[:city].empty? || params[:zip].empty?
      render :json => {:error => "Incomplete address"}, :status => 404
    elsif params[:zip].length != 5
      render :json => {:error => "Invalid zip code"}, :status => 404
    elsif params[:state].length != 2
      render :json => {:error => "Invalid state abbreviation"}, :status => 404
    else
      package_details
    end
  end

  
  def package_details
      package = build_package
      origin = set_origin
      destination = set_destination
      usps_rates = usps_request(origin, destination, package)
      ups_rates = ups_request(origin, destination, package)
      response = ups_rates + usps_rates
      log = make_string
      Request.create(option: log, ip: request.remote_ip)
      render json: response
  end

  def make_string
    x = []
    y = usps_request(set_origin, set_destination, build_package) + ups_request(set_origin, set_destination, build_package)
    y.each do |option|
      if option[0] == "UPS Ground" || option[0] == "UPS Second Day Air" || option[0] == "USPS Priority Mail 1-Day"
        x.push(option[0..1])
      end
    end
    x.to_s
  end

  def build_package
     package = Package.new(
      (params[:weight].to_f * 16),
      [params[:length].to_i, params[:width].to_i, params[:height].to_i],
      :units => :imperial
    )
    package
  end

  def set_origin
    origin = Location.new(
      :country => 'US',
      :state => 'WA',
      :city => 'Seattle',
      :zip => '98109',
    ) 
    origin
  end 
  
  def set_destination
   # elsif params[:state].length != 2
   #   render json: {error: "Please provide a valid state abbreviation"}, status: :400
   # else
      destination = Location.new(
        :country => 'US',
        :state => params[:state].upcase,
        :city => params[:city],
        :zip => params[:zip],
      ) 
      destination
   # end
  end
  
  def usps_request(origin, destination, package)
    usps = USPS.new(:login => ENV['USPS_ACCESS_KEY'])
    usps_response = usps.find_rates(origin, destination, package)
    usps_rates = usps_response.rates.sort_by(&:price).collect {
      |rate| [rate.service_name, rate.price]}
    usps_rates
  end

  def ups_request(origin, destination, package)
    ups = UPS.new(
      :login => 'auntjudy',
      :password => 'secret',
      :key => ENV['UPS_ACCESS_KEY']
    ) 
    ups_response = ups.find_rates(origin, destination, package)
    ups_rates = ups_response.rates.sort_by(&:price).collect {
      |rate| [rate.service_name, rate.price]}
    ups_rates
  end

end
