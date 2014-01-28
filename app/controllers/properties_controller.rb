class PropertiesController < ApplicationController
  def show

    @session_token = Rpdata.generate_token( 'bsguser.iproperty', 'x5yGCV85', '500998' , '43376848' )
    session[:rp_data_token] = @session_token

  	if !params[:address].blank?
  		rp_data_id = Rpdata.id_for_address( @session_token, params[:address] )
    else
  	 rp_data_id = '6168318'
    end
   	
   	@property_details = Rpdata.appraisal_data( @session_token, rp_data_id )
    @property_history = Rpdata.property_history( @session_token, rp_data_id )
    @comparable_otms = Rpdata.comparable_otms( @session_token, rp_data_id )
    
    @comparable_otms_avg_price = comparable_otms_avg_price( @comparable_otms )
    @comparable_otms_avg_dom = comparable_otms_avg_dom( @comparable_otms )
    @market_comparisons = Rpdata.comparable_sales( @session_token, rp_data_id )

    @market_comparisons_avg_price = comparable_sales_avg_sold( @market_comparisons )

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
