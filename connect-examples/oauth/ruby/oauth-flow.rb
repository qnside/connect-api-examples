# This sample demonstrates a bare-bones implementation of the Square Connect OAuth flow:
#
# 1. A merchant clicks the authorization link served by the root path (http://localhost:4567/)  
# 2. The merchant signs in to Square and submits the Permissions form. Note that if the merchant
#    is already signed in to Square, and if the merchant has already authorized your application,
#    the OAuth flow automatically proceeds to the next step without presenting the Permissions form.
# 3. Square sends a request to your application's Redirect URL
#    (which should be set to http://localhost:4567/callback on your application dashboard)
# 4. The server extracts the authorization code provided in Square's request and passes it
#    along to the Obtain Token endpoint.
# 5. The Obtain Token endpoint returns an access token your application can use in subsequent requests
#    to the Connect API.
#
# This sample requires the following gems:
#   sinatra (http://www.sinatrarb.com/)
#   unirest (http://unirest.io/ruby.html)

require 'sinatra'
require 'unirest'

# Your application's ID and secret, available from your application dashboard.
$application_id = 'REPLACE_ME'
$application_secret = 'REPLACE_ME'

# Headers to provide to OAuth API endpoints
$oauth_request_headers = { 'Authorization' => 'Client ' + $application_secret,
                           'Accept' => 'application/json',
                           'Content-Type' => 'application/json'}

$connect_host = 'https://connect.squareup.com'

# Serves the link that merchants click to authorize your application
get '/' do
  "<a href=\"https://connect.squareup.com/oauth2/authorize?client_id=#{$application_id}\">Click here</a>
            to authorize the application."
end

# Serves requsts from Square to your application's redirect URL
# Note that you need to set your application's Redirect URL to
# http://localhost:4567/callback from your application dashboard
get '/callback' do

  # Extract the returned authorization code from the URL
  authorization_code = params['code']

  if authorization_code

  	# Provide the code in a request to the Obtain Token endpoint
  	oauth_request_body = {
  	  'client_id' => $application_id,
  	  'client_secret' => $application_secret,
  	  'code' => authorization_code
  	}
  	response = Unirest.post $connect_host + '/oauth2/token',
                  headers: $oauth_request_headers,
                  parameters: oauth_request_body

    # Extract the returned access token from the response body
    if response.body.has_key?('access_token')

      # Here, instead of printing the access token, your application server should store it securely
      # and use it in subsequent requests to the Connect API on behalf of the merchant.
      puts 'Access token: ' + response.body['access_token']
      return 'Authorization succeeded!'

    # The response from the Obtain Token endpoint did not include an access token. Something went wrong.
    else
      return 'Code exchange failed!'
    end

  # The request to the Redirect URL did not include an authorization code. Something went wrong.
  else
  	return 'Authorization failed!'
  end
end