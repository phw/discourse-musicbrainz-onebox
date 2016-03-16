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
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=url-rels"
      end

      def match
        @match ||= @url.match(@@matcher)
      end

      def data
        return @data if @data

        @data = {
          link: @url,
          title: raw["name"]
        }

        disambiguation
        area
        life_span
        image "logo"

        return @data
      end
    end
  end
end
