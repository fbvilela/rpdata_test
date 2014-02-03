module PropertiesHelper

	def pretty_date(str)
    Date.parse(str.to_s).strftime("%d/%m/%Y") unless str.blank? 
  end

  def pretty_price(str)
    number_to_currency str, precision: 0
  end

end
