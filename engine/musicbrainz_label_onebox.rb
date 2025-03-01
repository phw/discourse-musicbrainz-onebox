require_relative "musicbrainz"

module Onebox
  module Engine
    class MusicBrainzLabelOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz

      matches_entity("label")
      always_https

      private

      def url
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=url-rels+genres"
      end

      def match
        @match ||= @url.match(@@matcher)
      end

      def data
        return @data if @data

        @data = {
          link: @url,
          id: raw["id"],
          title: raw["name"]
        }

        disambiguation
        area
        life_span
        genres
        image "logo"
        wikidata_image
        wikidata_wikilink
        add_critiquebrainz_link

        return @data
      end
    end
  end
end
