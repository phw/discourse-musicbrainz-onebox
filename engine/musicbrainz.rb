module Onebox
  module Engine
    module MusicBrainz
      include JSON

      def self.included(object)
        object.extend(ClassMethods)
      end

      private

      def artist_credits
        if raw["artist-credit"]
          raw["artist-credit"].reduce "" do |memo, credits|
            memo += credits["name"]
            memo += credits["joinphrase"] if credits["joinphrase"]
          end
        end
      end

      module ClassMethods
        def matches_entity(entity)
          class_variable_set :@@entity, entity
          matches_regexp(/^https?:\/\/(?:beta\.)?musicbrainz\.org\/#{Regexp.escape(entity)}\/(?<mbid>[0-9a-z-]+)/)
        end
      end

    end
  end
end
