class PropertiesController < ApplicationController
  def show

    @session_token = Rpdata.generate_token( 'bsguser.iproperty', 'x5yGCV85', '500998' , '43376848' )
    session[:rp_data_token] = @session_token
    session[:api_key] = 'bf3621c935c397a4f94e3adb49afaaa1270f4701'
    
  	if !params[:address].blank? 
  		rp_data_id = Rpdata.id_for_address( @session_token, params[:address] )
    else
  	 rp_data_id = Rpdata.id_for_address(@session_token, '7 Duke Street, Sunshine Beach QLD')
    end
   	
   	@property_details = Rpdata.appraisal_data( @session_token, rp_data_id )
    
    @history_details = Rpdata.property_details( @session_token, rp_data_id )
    
    @suburb_stats = Rpdata.suburb_stats(@session_token, @property_details.suburb, @property_details.post_code, @property_details.state )


    
        
    

   
    render :show2
   
  end

  def load_comparables
    @session_token = session[:rp_data_token]
    rp_data_id = params[:rp_data_id]
    #new way of getting recent sales and market comparison
    property = Rpdata.fetch_property(@session_token, rp_data_id)
    close_property_ids = Rpdata.property_ids_by_nearest_suburb( @session_token, rp_data_id ).collect(&:property_id)
    #this should return an array of ids.
    
    recent_sale_ids = Rpdata.refine_sold_properties( @session_token, close_property_ids, property )
    recent_sale_ids = [ recent_sale_ids ] unless recent_sale_ids.is_a?(Array)
    if recent_sale_ids.count < 5 
      recent_sale_ids = Rpdata.recent_sales( @session_token, close_property_ids )
    end

    @recent_sales = []
    recent_sale_ids.each do |sale_id|
      @recent_sales << Rpdata.property_summary( @session_token , sale_id )
    end

    
    
    otm_ids = Rpdata.refine_otm_properties( @session_token, close_property_ids, property )
    @comparable_otms = Rpdata.otm_property_summary_list( @session_token, otm_ids )
    @comparable_otms = [@comparable_otms] unless @comparable_otms.is_a?(Array)

    @comparable_otms_avg_price = comparable_otms_avg_price( @comparable_otms )
    @comparable_otms_avg_dom = comparable_otms_avg_dom( @comparable_otms )
    #end of the new way.

    @market_comparisons_avg_price = comparable_sales_avg_sold( @recent_sales )

    

    lat_long = [ ['-37.875799', '144.989866'], ['-37.874274', '144.987924'] , ['-37.872512','144.994597'] , ['-37.872986','145.002043'] ]
    @hash = Gmaps4rails.build_markers(lat_long) do |coordinate, marker|
      marker.lat coordinate.first
      marker.lng coordinate.last
      window_content = render_to_string( partial: 'infowindow', layout: false )
      marker.json({ :infowindow => window_content })
      #marker.json({ :infowindow => render_to_string(:patial => 'infowindow', :layout => false, :formats => [:html]) })
    end

    respond_to do |format|

      format.js
    end

  end

  def suggestions
    @session_token = session[:rp_data_token]
    response = Rpdata.suggestion_list( @session_token, params[:search])

    if response.keys.include?(:suggestions)
      list = response[:suggestions].collect do | suggestion| 
        [ suggestion[:property_id], suggestion[:single_line] ]
      end
    else
      list = [ [ response[:property_address_match][:property_id], response[:property_address_match][:single_line] ] ]
    end
    output = []
    list.each do |array|
      output << "<li style='cursor:pointer' class='suggestions' data-property='#{array.first}'>#{array.last}</li>"
    end
    output

    render text: output.join
  end

  private

  def comparable_otms_avg_price( comparable_otms )
    puts "what..." 
    puts comparable_otms.inspect
    comparable_otms.collect{|x| x[:current_listing_price].to_i}.sum / comparable_otms.count
  end

  def comparable_otms_avg_dom( comparable_otms )
    comparable_otms.collect{ |x| x[:days_otm].to_i }.sum / ( comparable_otms.count )
  end

  def comparable_sales_avg_sold( market_comparisons )
    market_comparisons.collect{ |x| x[:property_sale][:transfer_price].to_i }.sum / market_comparisons.count
  end

end
