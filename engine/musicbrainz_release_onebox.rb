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
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=artist-credits+release-groups+media+genres+url-rels"
      end

      def image_url
        "https://coverartarchive.org/#{@@entity}/#{match[:mbid]}/front-500"
      end

      def image_source_url
        "https://#{match[:domain]}/release/#{match[:mbid]}/cover-art"
      end

      def match
        @match ||= @url.match(@@matcher)
      end

      def data
        return @data if @data

        @data = {
          link: @url,
          title: raw["title"],
          status: raw["status"],
          date: raw["date"]
        }

        artist_credits
        disambiguation
        media_info
        genres
        wikidata

        if raw["release-group"]
          add_critiquebrainz_link(raw["release-group"]["id"], "release-group")
          genres raw["release-group"] if !@data[:genres]
        end

        caa = raw["cover-art-archive"]
        if caa && caa["artwork"] && caa["front"] && SiteSetting.musicbrainz_load_caa_images
          @data[:image] = image_url
          @data[:image_source] = image_source_url
          @data[:image_source_label] = "Cover Art Archive"
        end

        return @data
      end

      def media_info
        media = Hash.new(0)
        totaltracks = 0
        raw["media"].each do |m|
          media[m["format"]] += 1
          totaltracks += m["track-count"] || 0
        end
        @data[:media] = join_list(media.map do |medium, count|
          count > 1 ? "#{count}×#{medium}" : medium
        end)
        @data[:totaltracks] = totaltracks if totaltracks > 0
        puts "totaltracks #{totaltracks} - #{@data[:totaltracks]}"
      end
    end
  end
end
