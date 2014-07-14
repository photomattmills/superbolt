module Superbolt
  module Runner
    class Pg < Default
      def on_error(message, error)
        if error == PG::UnableToSend || error == PG::ConnectionBad
          ActiveRecord::Base.connection.reset!
        end

        super
      end
    end
  end
end
