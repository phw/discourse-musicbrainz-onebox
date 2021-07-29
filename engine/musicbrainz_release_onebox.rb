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
        description

        caa = raw["cover-art-archive"]
        if caa && caa["artwork"] && caa["front"]
          @data[:image] = image_url
          @data[:image_source] = image_source_url
          @data[:image_source_label] = I18n.t("general.image_source")
        end

        return @data
      end

      def description
        key = if @data[:artist] && @data[:date]
          "release.description_artist_date"
        elsif @data[:artist]
          "release.description_artist"
        elsif @data[:date]
          "release.description_date"
        else
          "release.description"
        end
        @data[:description] = I18n.t(key, @data)
      end

    end
  end
end
