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
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=artist-rels+url-rels+work-rels"
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
        }

        @data[:type] = "Work" if @data[:type].to_s.empty?

        disambiguation
        add_critiquebrainz_link
        image
        wikidata
        written_by
        parent_work

        return @data
      end

      def written_by
        writers = get_relations(
          "artist", ["writer", "lyricist", "composer", "librettist"], direction: "backward")
        @data[:writers] = join_sentence(writers.map { |rel| rel.dig("artist", "name") })
      end

      def parent_work
        parent = get_relations("work", ["parts"], direction: "backward").first
        return if parent.nil?
        @data[:parent_work] = parent.dig("work", "title")
        @data[:parent_work_url] = get_mb_url("work", parent.dig("work", "id"))
      end

    end
  end
end
