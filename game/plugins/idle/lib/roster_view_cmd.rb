module AresMUSH

  module Idle
    class RosterViewCmd
      include CommandHandler
      
      attr_accessor :name

      def parse_args
        self.name = titlecase_arg(cmd.args)
      end
      
      def required_args
        {
          args: [ self.name ],
          help: 'roster'
        }
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          if (!model.on_roster?)
            client.emit_failure t('idle.not_on_roster', :name => model.name)
            return
          end
          
          template = RosterDetailTemplate.new model
          client.emit template.render
        end
      end
    end
  end
end
