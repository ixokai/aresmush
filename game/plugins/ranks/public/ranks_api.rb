module AresMUSH
  module Ranks
    def self.app_review(char)
      message = t('ranks.app_review')
      
      if (!char.rank)
        status = t('chargen.are_you_sure', :missing => t('ranks.review_rank_missing'))
      elsif Ranks.check_rank(char, char.rank, false)
        status = t('ranks.review_rank_invalid')
      else
        status = t('chargen.ok')
      end
      
      Chargen.format_review_status(message, status)
    end
    
    def self.military_name(char)
      fullname = char.demographic(:fullname) || char.name
      first_name = fullname.first(" ")
      last_name = fullname.rest(" ")
      rank_str = char.rank ? "#{char.rank} " : ""
      callsign = char.demographic(:callsign)
      callsign_str =  callsign.blank? ? "" : "\"#{callsign}\" "
      "#{rank_str}#{first_name} #{callsign_str}#{last_name}"
    end
  end
end