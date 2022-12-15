require_relative "musicbrainz"

module Onebox
  module Engine
    class MusicBrainzEventOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz

      matches_entity("event")
      always_https

      private

      def url
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=place-rels+artist-rels+url-rels"
      end

      def match
        @match ||= @url.match(@@matcher)
      end

      def data
        return @data if @data

        @data = {
          link: @url,
          id: raw["id"],
          title: raw["name"],
          type: raw["type"]
        }

        disambiguation
        life_span
        add_critiquebrainz_link
        image
        wikidata
        place
        performers

        return @data
      end

      def place
        place_rel = get_relations("place", ["held at"]).first
        if place_rel && place_rel["place"]
          place = place_rel["place"]
          @data[:place] = place["name"]
          @data[:area] = place.dig("area", "name")
        end
      end

      def performers
        performer_rels = get_relations("artist", ["main performer"]) +
          get_relations("artist", ["support act"]) +
          get_relations("artist", ["orchestra"]) +
          get_relations("artist", ["guest performer"])
        performers = performer_rels.map { |rel| rel.dig("artist", "name") }
        @data[:performers] = join_sentence(performers)
      end
    end
  end
end
