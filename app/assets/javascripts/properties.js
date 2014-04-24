

$(function(){

  $('#ajax_indicator').fadeOut();

	$('#address_input').keyup(function(){
	 var value = $(this).val();
	  if( value.length > 7) {
	   	$.post("/properties/suggestions", { search: value }, function(html){
        $('#suggestion_list').empty();
        $('#suggestion_list').show();
        $('#suggestion_list').append(html);

        $('.suggestions').click(function(){
          $('#address_input').val( $(this).text() );
          $('#suggestion_list').hide();
          $('#address_input').blur();
        });

      });


	   } //if
	});


  
});

function setup_map(data){ 
handler = Gmaps.build('Google');
handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
  markers = handler.addMarkers(data);
  handler.bounds.extendWith(markers);
  handler.fitMapToBounds();
});

}


