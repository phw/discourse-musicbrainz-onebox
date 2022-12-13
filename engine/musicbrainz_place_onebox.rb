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
          type: raw["type"] != "Other" ? raw["type"] : "Place"
        }

        disambiguation
        area
        life_span
        add_critiquebrainz_link
        image
        wikidata

        return @data
      end
    end
  end
end
