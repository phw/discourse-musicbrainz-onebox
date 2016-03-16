require_relative "musicbrainz"

module Onebox
  module Engine
    class MusicBrainzArtistOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz

      matches_entity("artist")
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
          title: raw["name"],
          type: raw["type"]
        }

        disambiguation
        area
        life_span
        image

        return @data
      end
    end
  end
end
