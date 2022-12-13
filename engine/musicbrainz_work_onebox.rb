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
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=artist-rels+url-rels"
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
          type: raw["type"],
          writers: written_by
        }

        @data[:type] = "Work" if @data[:type].to_s.empty?

        disambiguation
        add_critiquebrainz_link
        image
        wikidata

        return @data
      end

      def written_by
        writers = get_relations(
          "artist", ["writer", "lyricist", "composer", "librettist"], "backward")
        join_sentence(writers.map { |rel| rel["artist"]["name"] })
      end

    end
  end
end
