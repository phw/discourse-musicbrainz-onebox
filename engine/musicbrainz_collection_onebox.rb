require_relative "musicbrainz"

module Onebox
  module Engine
    class MusicBrainzCollectionOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz

      matches_entity("collection")
      always_https

      private

      def url
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json"
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
          type: raw["type"],
          editor: raw["editor"],
          entity: raw["entity-type"],
          count: raw["#{raw["entity-type"]}-count"]
        }

        return @data
      end
    end
  end
end
