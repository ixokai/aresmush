module AresMUSH
  module Weather
    mattr_accessor :current_weather
   
    def self.can_change_weather?(actor)
      actor.has_permission?("manage_weather")
    end
    
    def self.load_weather_if_needed
      if (Weather.current_weather == {})
        Weather.change_all_weathers
      end
    end

    def self.change_all_weathers
      # Set an initial weather for each area and the default one
      Weather.current_weather = {}
      areas = Global.read_config("weather", "climate_for_area").keys + ["default"]
      areas.each do |a|
        Weather.change_weather(a)
      end
    end
      
    def self.change_weather(area)
      # Figure out the climate for this area
      climate = Weather.climate_for_area(area)

      # Save no weather if the weather is disabled for this area.
      if (climate == "none")
        Weather.current_weather[area] = ""
        return
      end

      season = ICTime.season(area)
      
      climate_config = Global.read_config("weather", "climates", climate)
      season_config = climate_config[season]

      # Get the current weather
      weather = Weather.current_weather[area]

      # Make a stability roll to see if the weather actually changes.  
      # Also change it if the weather was never set.
      if (!weather || rand(100) < season_config["stability"])
        weather = Weather.random_weather(season_config)
      end

      # Save the weather!
      Weather.current_weather[area] = weather
    end

    def self.random_weather(season_config)
      condition = season_config["condition"].split(/ /).shuffle.first
      temperature = season_config["temperature"].split(/ /).shuffle.first
      
      { :condition => condition, :temperature => temperature }
    end
    
    def self.climate_for_area(area)
      Global.read_config("weather", "climate_for_area", area) || Global.read_config("weather", "default_climate")
    end
  end
end