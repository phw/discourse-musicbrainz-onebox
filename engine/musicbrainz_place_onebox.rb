require_relative "musicbrainz"

module Onebox
  module Engine
    class MusicBrainzPlaceOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz

      matches_entity("place")
      always_https

      private

      def url
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=url-rels"
      end

      def match
        @match ||= @url.match(@@matcher)
      end

      def data
        return @data if @data

        @data = {
          link: @url,
          id: raw["id"],
          title: raw["name"],
          type: raw["type"] != "Other" ? raw["type"] : I18n.t("place.type")
        }

        disambiguation
        area
        life_span
        image
        description

        return @data
      end

      def description
        key = if @data[:area] && @data[:lifespan]
          "place.description_area_date"
        elsif @data[:area]
          "place.description_area"
        elsif @data[:lifespan]
          "place.description_date"
        else
          "place.description"
        end
        @data[:description] = I18n.t(key, @data)
      end
    end
  end
end
