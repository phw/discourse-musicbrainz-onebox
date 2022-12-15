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
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=artist-credits+genres+url-rels"
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
        }

        artist_credits
        disambiguation
        genres
        add_critiquebrainz_link
        caa_image
        wikidata

        if raw["secondary-types"] && !raw["secondary-types"].empty?
          @data[:secondary] = raw["secondary-types"].join(", ")
        end

        return @data
      end

      def caa_image
        return nil if !SiteSetting.musicbrainz_load_caa_images
        coverart_url = nil
        begin
          api_url = "https://coverartarchive.org/#{@@entity}/#{match[:mbid]}"
          result = request_json(api_url)

          image = result["images"][0] if result["images"]
          if image && image["thumbnails"]
            thumbnails = image["thumbnails"]
            @data[:image] = thumbnails["500"] ||
              thumbnails["large"] ||
              thumbnails["250"] ||
              thumbnails["small"]
            @data[:image_source] = result["release"]
            @data[:image_source_label] = "Cover Art Archive"
          end

        rescue OpenURI::HTTPError => e
          # 404 means the release group does not exist or has no cover art.
          # Everything else is unexpected and logged as an error.
          Rails.logger.error e.message unless e.io.status[0] == "404"
        end

        return coverart_url
      end

    end
  end
end
