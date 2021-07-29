require_relative 'musicbrainz'

module Onebox
  module Engine
    class MusicBrainzWorkOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz

      matches_entity("work")
      always_https

      private

      def url
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=artist-rels"
      end

      def match
        @match ||= @url.match(@@matcher)
      end

      def data
        return @data if @data

        @data = {
          link: @url,
          title: raw["title"],
          type: raw["type"],
          writers: writers
        }

        @data[:type] = I18n.t("work.type") if @data[:type].to_s.empty?

        disambiguation
        description

        return @data
      end

      def description
        key = if @data[:writers]
          "work.description_writers"
        else
          "work.description"
        end
        @data[:description] = I18n.t(key, @data)
      end

      def writers
        writers = get_relations(
          "artist", ["writer", "lyricist", "composer", "librettist"], "backward")
        if writers.empty?
          nil
        else
          join_sentence(writers.map { |rel| rel["artist"]["name"] })
        end
      end

    end
  end
end
