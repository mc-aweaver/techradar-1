Airbrake.configure do |config|
  config.api_key = ENV['AIRBRAKE_API_KEY'] || raise("Missing AIRBRAKE_API_KEY")
end
