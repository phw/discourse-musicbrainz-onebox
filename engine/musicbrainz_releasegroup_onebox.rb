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
        coverart_url = nil
        begin
          api_url = "https://coverartarchive.org/#{@@entity}/#{match[:mbid]}"
          open(api_url,
            "User-Agent" => "discourse-musicbrainz-onebox",
            :read_timeout => timeout,
            :redirect => false
            )
        rescue OpenURI::HTTPRedirect => e
          # Redirect indicates there is release group cover art available
          coverart_url = "https://coverartarchive.org/#{@@entity}/#{match[:mbid]}/front-500"
        rescue OpenURI::HTTPError => e
          # 404 means the release group does not exist or has no cover art.
          # Everything else is unexpected and logged as an error.
          Rails.logger.error e.message unless e.io.status[0] == "404"
        end

        return coverart_url
      end

      def match
        @match ||= @url.match(@@matcher)
      end

      def data
        return @data if @data

        @data = {
          link: @url,
          id: raw["id"],
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
