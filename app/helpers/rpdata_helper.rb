require 'openssl'
module RpdataHelper

  def sales_cma_link(property_id)
    hash = {src: "test", inputPropertyId: property_id}
    build_url do |params|
      link_to( image_tag("cma.png") + " CMA Report" , "#{base_link_url}flow/cma.html?#{hash.merge(params).to_query}", { target: "_blank"})
    end
  end

  def rental_cma_link(property_id)
    hash = {src: "test", inputPropertyId: property_id}
    build_url do |params|
      link_to( image_tag("rcma.png") + " RCMA Report" , "#{base_link_url}flow/rental-cma.html?#{hash.merge(params).to_query}", { target: "_blank"})
    end
  end

  def avm_link(property_id)
    hash = {src: "test", inputPropertyId: property_id}
    build_url do |params|
      link_to( image_tag("avm.png") + " AVM Report" , "#{base_link_url}flow/avm.html?#{hash.merge(params).to_query}", { target: "_blank"})
    end
  end

  def rpp_property_link(property_id)
    hash = { propertyId: property_id, is_workflow: 'false' , showNavBtns: 'false' }
    build_url do |params|
      link_to( image_tag('IconRPPro.png') + " Rpp property detail", "#{base_link_url}property/detail.html?#{hash.merge(params).to_query}".encode('utf-8'), {target: '_blank'} )
    end   
  end

  private

  def base_link_url
    "https://rppstage.rpdata.com/rpp/"
  end

  def build_url 
    key = session[:api_key]
    part1 = { timestamp: timestamp, token: session[:rp_data_token], apiKey: key }
    hash_part = { hash: OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), key, part1.to_query).to_s } 
    yield part1.merge(hash_part)
  end

  def timestamp 
    Time.now.iso8601
  end

end