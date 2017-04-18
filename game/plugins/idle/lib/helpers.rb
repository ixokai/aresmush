module AresMUSH
  module Idle
    def self.can_idle_sweep?(actor)
      actor.has_permission?("idle_sweep")
    end
    
    def self.can_manage_roster?(actor)
      actor.has_permission?("manage_roster")
    end
    
    def self.create_or_update_roster(client, enactor, name, contact)
      ClassTargetFinder.with_a_character(name, client, enactor) do |model|
        Idle.add_to_roster(model, contact)
        client.emit_success t('idle.roster_updated')
      end
    end
    
    def self.add_to_roster(char, contact = nil)
      char.update(roster_contact: contact || Global.read_config("idle", "default_contact"))
      char.update(idle_state: "Roster")
      # Reset their password.
      Login::Api.set_random_password(char)
      # Remove their handle.              
      if (char.handle)
        char.handle.delete
      end
    end
    
    def self.remove_from_roster(char)
      char.update(idle_state: nil)
    end
    
    def self.is_exempt?(actor)
      actor.has_permission?("idle_exempt")
    end
        
    def self.active_chars
      base_list = Character.all
      base_list.select { |c| !(c.idled_out? || c.is_admin? || c.is_playerbit? || 
        c.is_guest? || c.is_npc? || c.on_roster? )}
    end
    
    def self.idle_action_color(action)
    	case action
         when "Destroy"
           color = "%xh%xx"
         when "Warn"
           color = "%xh"
         when "Npc"
           color = "%xb"
         when "Dead"
           color = "%xh%xr"
         when "Gone"
           color = "%xh%xy"
         when "Roster"
           color = "%xh%xg"
         else
           color = "%xc"
       end
     end
    
  end
end