module HomeHelper
  def cred
    Rails.cache.fetch('credentials', :expires_in => 2.minutes) do
      Rails::env == 'development' ?
        YAML.load(File.read('config/f00px.yml')) : ENV
    end
  end

  def oauth_consumer
    OAuth::Consumer.new(
      cred['consumer_key'],
      cred['consumer_secret'],
      {
        :site => "https://api.500px.com",
        :request_token_path => "/v1/oauth/request_token",
        :access_token_path  => "/v1/oauth/access_token",
        :authorize_path     => "/v1/oauth/authorize"
      }
    )
  end

  def base_uri
    "https://api.500px.com/v1"
  end

  def serialize( params )
    params.map { |k,v| "#{k}=#{v}" }.join('&')
  end

  # Doesn't work #1
  # # Step one + two
  # def oauth
  #   @callback_url = "http://127.0.0.1:3000/top"
  #   @request_token = consumer.get_request_token(
  #     oauth_callback: @callback_url)

  #   session[:request_token] = @request_token
  #   redirect_to @request_token.authorize_url(
  #     oauth_callback: @callback_url)
  # end

  # # Step three
  # def prepare_access_token
  #   request_token = OAuth::RequestToken.from_hash(
  #     consumer, session[:request_token] )

  #   return request_token.get_access_token
  # end

  # Doesn't work #2
  # def configure_f00( access_token )
  #   F00px.configure do |config|
  #     config.consumer_key = cred['consumer_key']
  #     config.consumer_secret = cred['consumer_secret']
  #     config.token = access_token.token
  #     config.token_secret = access_token.secret
  #   end
  # end

  def xauth_token
    consumer = oauth_consumer
    request_token = consumer.get_request_token
    consumer.get_access_token(
      request_token, {},
      {
        :x_auth_mode => 'client_auth',
        :x_auth_username => cred['username'],
        :x_auth_password => cred['password']
      }
    )
  end


  # Public routes
  def popular( num = 20 )
    results = []
    page = 0
    while results.count < num
      query = serialize({
        consumer_key: cred['consumer_key'],
        feature: 'popular',
        page: page += 1
      })

      results.concat HTTParty.get("#{base_uri}/photos?#{query}").
                              parsed_response["photos"].
                              first(num - results.count)
    end

    results.map{ |r|
      {
        id: r['id'],
        url: r['image_url']
      }
    }
  end

  # Authenticated Routes
  def vote( id, v )
    # access_token = prepare_access_token(
    #   session[:request_token]['params']['oauth_token'],
    #   session[:request_token]['params']['oauth_token_secret'])

    # Doesn't work #1
    # response = access_token.post("#{base_uri}/photos/#{id}/vote?vote=#{v}")

    # Doesn't work #2
    # configure_f00( access_token )

    # Doesn't work #3
    # client = F00px::Client.new
    # client.token = access_token.token
    # client.token_secret = access_token.secret

    access_token = xauth_token
    response = access_token.post("/v1/photos/#{params[:id]}/vote.json?vote=1")
    return response.body
  end

end