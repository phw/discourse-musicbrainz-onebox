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
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=artist-credits+release-groups+media+genres+url-rels+release-group-level-rels"
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
          id: raw["id"],
          title: raw["title"],
          status: raw["status"],
          date: raw["date"]
        }

        artist_credits
        disambiguation
        media_info
        genres
        caa_image
        wikidata_image
        wikidata_wikilink

        release_group = raw["release-group"]
        if release_group
          genres(release_group) if !@data[:genres]
          caa_rg_image(release_group["id"]) if !@data[:image]
          wikidata_image(release_group)
          wikidata_wikilink(release_group)
          add_critiquebrainz_link(release_group["id"], "release-group")
        end

        add_listenbrainz_link
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
          count > 1 ? "#{format_number(count)}×#{medium}" : medium
        end)
        @data[:totaltracks] = format_number(totaltracks) if totaltracks > 0
      end

      def caa_image
        caa = raw["cover-art-archive"]
        if caa && caa["artwork"] && caa["front"] && SiteSetting.musicbrainz_load_caa_images
          @data[:image] = image_url
          @data[:image_source] = image_source_url
          @data[:image_source_label] = "Cover Art Archive"
        end
      end

      def add_listenbrainz_link
        add_external_link(
          :url => "https://listenbrainz.org/player/#{self.class.entity}/#{@data[:id]}",
          :icon => "listenbrainz.svg",
          :title => "Play on ListenBrainz",
          :alt => "LB",
        )
      end
    end
  end
end
