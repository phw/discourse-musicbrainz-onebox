require_relative 'musicbrainz'

module Onebox
  module Engine
    class MusicBrainzReleaseOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz

      matches_entity("release")
      always_https

      private

      def url
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=artist-credits"
      end

      def image_url
        "https://coverartarchive.org/#{@@entity}/#{match[:mbid]}/front-500"
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
          data[:image] = image_url
        end

        @data = data
      end

    end
  end
end
