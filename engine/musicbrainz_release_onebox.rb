module Onebox
  module Engine
    class MusicBrainzReleaseOnebox
      include Engine
      include LayoutSupport
      include JSON

      matches_regexp(/^https?:\/\/(?:beta\.)?musicbrainz\.org\/release\/(?<mbid>[0-9a-z-]+)/)
      always_https

      private

      def url
        "https://musicbrainz.org/ws/2/release/#{match[:mbid]}?fmt=json&inc=artist-credits"
      end

      def match
        @match ||= @url.match(@@matcher)
      end

      def data
        return @data if @data

        data = {
          link: @url,
          title: raw["title"],
          date: raw["date"],
          artist: artist_credits
        }

        if !raw["disambiguation"].to_s.empty?
          data[:disambiguation] = raw["disambiguation"]
        end

        caa = raw["cover-art-archive"]
        if caa && caa["artwork"] && caa["front"]
          data[:image] = "https://coverartarchive.org/release/#{match[:mbid]}/front-500"
        end

        @data = data
      end

      def artist_credits
        if raw["artist-credit"]
          raw["artist-credit"].reduce "" do |memo, credits|
            memo += credits["name"]
            memo += credits["joinphrase"] if credits["joinphrase"]
          end
        end
      end
    end
  end
end
