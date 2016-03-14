require 'onebox'

module Onebox
  module Engine
    class MusicBrainzArtistOnebox
      include Engine
      include LayoutSupport
      include JSON

      matches_regexp(/^https?:\/\/(?:beta\.)?musicbrainz\.org\/artist\/(?<mbid>[0-9a-z-]+)/)
      always_https

      private

      def url
        "https://musicbrainz.org/ws/2/artist/#{match[:mbid]}?fmt=json"
      end

      def match
        @match ||= @url.match(@@matcher)
      end

      def data
        return @data if @data

        data = {
          link: @url,
          title: raw["name"],
          type: raw["type"]
        }

        if !raw["disambiguation"].to_s.empty?
          data[:disambiguation] = raw["disambiguation"]
        end

        data[:area] = raw["area"]["name"] if raw["area"]

        if raw["life-span"]
          data[:begin] = raw["life-span"]["begin"]
          data[:end] = raw["life-span"]["end"]

          if !data[:end] && raw["life-span"]["ended"]
            data[:end] = "????"
          end
        end

        @data = data
      end
    end
  end
end
