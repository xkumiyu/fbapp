#
# $.getJSON 'users/data', (data) ->
#   # ulObj = $("#demo")
#   # len = data.length
#   console.log data
#
#   xmlHttpRequest = new XMLHttpRequest()
#   xmlHttpRequest.onreadystatechange = () ->
#     READYSTATE_COMPLETED = 4
#     HTTP_STATUS_OK = 200
#
#     if( this.readyState == READYSTATE_COMPLETED && this.status == HTTP_STATUS_OK )
#       alert this.responseText
#
#   xmlHttpRequest.open 'POST', '/users'
#   xmlHttpRequest.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
#
#   EncodeHTMLForm = ( data ) ->
#     params = []
#     for name in data
#       value = data[ name ]
#       param = encodeURIComponent( name ).replace( /%20/g, '+' ) + '=' + encodeURIComponent( value ).replace( /%20/g, '+' )
#       params.push( param );
#     params.join( '&' )
#
#   xmlHttpRequest.send EncodeHTMLForm( data )
#
#   # for i in [0..len]
#   #   ulObj.append $("<li>").attr({"id":data[i].id}).text(data[i].name)
#
#
# # localStorage.setItem 'key', 'val'
