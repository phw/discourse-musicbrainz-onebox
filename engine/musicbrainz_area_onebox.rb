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
        wikidata_image
        wikidata_wikilink
        wikidata_symbol

        return @data
      end

      def wikidata_allowed?
        # Always allow to load flag symbol
        true
      end
    end
  end
end
