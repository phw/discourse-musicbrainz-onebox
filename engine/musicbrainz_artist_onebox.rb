require_relative "musicbrainz"
require_relative "wikimedia"

module Onebox
  module Engine
    class MusicBrainzArtistOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz
      include Wikimedia

      matches_entity("artist")
      always_https

      private

      def url
        "https://musicbrainz.org/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=url-rels"
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

        images = get_relations("url", ["image"], "forward")
        if !images.empty?
          data[:image] = image_url(images.first["url"]["resource"])
          if !data[:image].nil?
            data[:image_source] = images.first["url"]["resource"]
          end
        end

        @data = data
      end
    end
  end
end
