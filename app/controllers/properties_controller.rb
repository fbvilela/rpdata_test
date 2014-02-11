class PropertiesController < ApplicationController
  def show

    @session_token = Rpdata.generate_token( 'bsguser.iproperty', 'x5yGCV85', '500998' , '43376848' )
    session[:rp_data_token] = @session_token
    session[:api_key] = '8f894f92ce07e843e5b63756a1a600018d87aa04'
    
  	if !params[:address].blank? 
  		rp_data_id = Rpdata.id_for_address( @session_token, params[:address] )
    else
  	 rp_data_id = '6168318'
    end
   	
   	@property_details = Rpdata.appraisal_data( @session_token, rp_data_id )
    
    @property_history = Rpdata.property_history( @session_token, rp_data_id ) #this is still using valuers

    @history_details = Rpdata.property_details( @session_token, rp_data_id )
    puts "what historory details:"
    puts @history_details

    @comparable_otms = Rpdata.comparable_otms( @session_token, rp_data_id )
    
    @comparable_otms_avg_price = comparable_otms_avg_price( @comparable_otms )
    @comparable_otms_avg_dom = comparable_otms_avg_dom( @comparable_otms )
    @market_comparisons = Rpdata.comparable_sales( @session_token, rp_data_id )

    @market_comparisons_avg_price = comparable_sales_avg_sold( @market_comparisons )

    @suburb_stats = Rpdata.suburb_stats(@session_token, @property_details.suburb, @property_details.post_code, @property_details.state )

    lat_long = [ ['-37.875799', '144.989866'], ['-37.874274', '144.987924'] , ['-37.872512','144.994597'] , ['-37.872986','145.002043'] ]
    @hash = Gmaps4rails.build_markers(lat_long) do |coordinate, marker|
      marker.lat coordinate.first
      marker.lng coordinate.last
      window_content = render_to_string( partial: 'infowindow', layout: false )
      marker.json({ :infowindow => window_content })
      #marker.json({ :infowindow => render_to_string(:patial => 'infowindow', :layout => false, :formats => [:html]) })
    end

    if request.path =~ /valuers/ 
      render :show
    else
      render :show2
    end
  end

  private

  def comparable_otms_avg_price( comparable_otms )
    comparable_otms.collect{|x| x.price.to_i}.sum / comparable_otms.count
  end

  def comparable_otms_avg_dom( comparable_otms )
    comparable_otms.collect{ |x| Date.today.mjd - ( Date.parse( x.listed_date.to_s ).mjd )  }.sum / ( comparable_otms.count )
  end

  def comparable_sales_avg_sold( market_comparisons )
    market_comparisons.collect{ |x| x.price.to_i }.sum / market_comparisons.count
  end

end
