class GuestPreferenceService
    PREFERENCE_KEYS = [:post_order, :other_preference].freeze
  
    # READ & STORE THE KEYS IN THE COOKIES
    def self.update_guest_preferences(cookies, preferences)  
      # :post_order => "newest" # key , value
      preferences.each do |key, value|
        cookies.permanent[key] = value
        puts "Guest preference service, cookies.permanent[#{key}] = #{value}" 

      end
    end

    # METHOD FOR THE app/controllers/users/sessions_controller.rb
     # DELETE GUESTS COOKIES
     def self.delete_guest_preferences(cookies)
        PREFERENCE_KEYS.each do |key|
          cookies.delete(key)
          puts "Guest preference service, cookies.delete(#{key})"
        end
     end


    # METHOD FOR THE app/controllers/users/sessions_controller.rb
     # CHECK IF THE PREFERENCES EXISTS
     def self.guest_preferences_present?(cookies)
       PREFERENCE_KEYS.any? { |key| cookies[key].present? }
     end
  
  end