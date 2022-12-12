require_relative "musicbrainz"

module Onebox
  module Engine
    class MusicBrainzSeriesOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz

      matches_entity("series")
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
        image

        return @data
      end
    end
  end
end
