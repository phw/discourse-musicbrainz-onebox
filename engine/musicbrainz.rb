require_relative "wikimedia_image"

module Onebox
  module Engine
    module MusicBrainz
      include Onebox::Mixins::WikimediaImage

      # Reimplement JSON mixin with proper user agent
      def raw
        begin
          @raw ||= ::MultiJson.load(open(url,
            "User-Agent" => "discourse-musicbrainz-onebox",
            :read_timeout => timeout
            ))
        rescue OpenURI::HTTPError => e
          Rails.logger.error e.message
          raise
        end
      end

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
        if raw["life-span"] && (raw["life-span"]["begin"] || raw["life-span"]["ended"])
          @data[:begin] = raw["life-span"]["begin"]
          @data[:begin] = "????" if !@data[:begin]
          @data[:end] = raw["life-span"]["end"]

          if !@data[:end] && raw["life-span"]["ended"]
            @data[:end] = "????"
          end

          @data[:lifespan] = #{@data[:begin]}
          if @data[:end]
            @data[:lifespan] += "– #{@data[:end]}"
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

      def join_sentence(arr, limit=5, limit_phrase="others")
        arr = arr.uniq.reject(&:nil?)
        if arr.empty?
          return nil
        elsif arr.length == 1
          return arr[0]
        elsif arr.length > limit
          arr = arr[0..limit-2].push(limit_phrase)
        end
        return "#{arr[0..-2].join(', ')} and #{arr.last}"
      end

      def join_list(arr)
        arr = arr.reject(&:nil?)
        return arr.join(', ')
      end

      def get_mb_url(entity, mbid)
        "https://#{match[:domain]}/#{entity}/#{mbid}"
      end

      module ClassMethods
        def matches_entity(entity)
          class_variable_set :@@entity, entity
          matches_regexp(/^https?:\/\/(?<domain>(?:beta\.)?musicbrainz\.org)\/#{Regexp.escape(entity)}\/(?<mbid>[0-9a-z-]{36})(?!\/(?:edit|open_edits))/)
        end
      end

    end
  end
end
