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

      def get_relations(targetEntity, types, direction=nil)
        return [] if !raw["relations"]

        return raw["relations"].select do |rel|
          rel["target-type"] == targetEntity &&
            types.include?(rel["type"]) &&
            (direction.nil? || rel["direction"] == direction)
        end
      end

      def get_mb_url(entity, mbid)
        "https://#{match[:domain]}/#{entity}/#{mbid}"
      end

      module ClassMethods
        def matches_entity(entity)
          class_variable_set :@@entity, entity
          matches_regexp(/^https?:\/\/(?<domain>(?:beta\.)?musicbrainz\.org)\/#{Regexp.escape(entity)}\/(?<mbid>[0-9a-z-]+)/)
        end
      end

    end
  end
end
