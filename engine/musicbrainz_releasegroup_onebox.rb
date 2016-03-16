require_relative 'musicbrainz'

module Onebox
  module Engine
    class MusicBrainzReleaseGroupOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz

      matches_entity("release-group")
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

        @data = {
          link: @url,
          title: raw["title"],
          date: raw["first-release-date"],
          type: raw["primary-type"],
          image: image_url
        }

        artist_credits
        disambiguation

        if raw["secondary-types"] && !raw["secondary-types"].empty?
          @data[:secondary] = raw["secondary-types"].join(", ")
        end

        return @data
      end

    end
  end
end
