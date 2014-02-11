

function setup_map(data){ 
handler = Gmaps.build('Google');
handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
  markers = handler.addMarkers(data);
  handler.bounds.extendWith(markers);
  handler.fitMapToBounds();
});

}


