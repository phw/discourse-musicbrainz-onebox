require_relative "musicbrainz"

module Onebox
  module Engine
    class MusicBrainzAreaOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz

      matches_entity("area")
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
          type: raw["type"]
        }

        disambiguation
        life_span
        wikidata_data = wikidata

        wikidata_symbol(wikidata_data)

        return @data
      end

      def wikidata_symbol(data)
        unicode_char = data.dig("claims", WIKIDATA_TYPE_UNICODE_CHARACTER)&.first
        @data["symbol"] = unicode_char&.dig("mainsnak", "datavalue", "value")
      end
    end
  end
end
