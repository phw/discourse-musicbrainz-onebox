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
        caa_rg_image(raw["id"])
        wikidata_image
        wikidata_wikilink

        if raw["secondary-types"] && !raw["secondary-types"].empty?
          @data[:secondary] = join_list(raw["secondary-types"])
        end

        return @data
      end
    end
  end
end
