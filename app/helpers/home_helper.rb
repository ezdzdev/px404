module HomeHelper
  def cred
    if Rails::env == 'development'
      credentials = YAML.load(File.read('config/f00px.yml'))
    else
      credentials = ENV
    end

    credentials
  end

  def base_uri
    "https://api.500px.com/v1"
  end

  def serialize( params )
    params.map { |k,v| "#{k}=#{v}" }.join('&')
  end

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

    results.map{ |r| r['image_url'] }
  end
end