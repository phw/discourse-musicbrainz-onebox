require_relative "wikimedia"

module Onebox
  module Engine
    module MusicBrainz
      include JSON
      include Wikimedia

      def self.included(object)
        object.extend(ClassMethods)
      end

      private

      # Common data helpers
      def disambiguation
        if !raw["disambiguation"].to_s.empty?
          @data[:disambiguation] = raw["disambiguation"]
        end
      end

      def area
        @data[:area] = raw["area"]["name"] if raw["area"]
      end

      def life_span
        if raw["life-span"]
          @data[:lifespan] = true
          @data[:begin] = raw["life-span"]["begin"]
          @data[:end] = raw["life-span"]["end"]

          if !@data[:end] && raw["life-span"]["ended"]
            @data[:end] = "????"
          end
        end
      end

      def artist_credits
        if raw["artist-credit"]
          @data[:artist] = raw["artist-credit"].reduce "" do |memo, credits|
            memo += credits["name"]
            memo += credits["joinphrase"] if credits["joinphrase"]
          end
        end
      end

      def image(type="image")
        image = get_relations("url", [type]).first
        if image
          @data[:image] = wikimedia_image_url(image["url"]["resource"])
          if !@data[:image].nil?
            @data[:image_source] = image["url"]["resource"]
          end
        end
      end

      # General helper functions
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
