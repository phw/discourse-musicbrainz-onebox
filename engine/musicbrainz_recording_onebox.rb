require_relative 'musicbrainz'

module Onebox
  module Engine
    class MusicBrainzRecordingOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz

      matches_entity("recording")
      always_https

      private

      def url
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=artist-credits+work-rels"
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
          duration: format_duration,
        }

        artist_credits
        disambiguation
        add_critiquebrainz_link
        wikidata

        types = []
        primary_type = (raw["video"] ? "video" : "recording")

        work_rel = get_relations("work", ["performance"]).first
        if work_rel
          attributes = work_rel["attributes"]
          types << "live" if attributes.include? "live"
          types << "instrumental" if attributes.include? "instrumental"
          types << "cover" if attributes.include? "cover"
          primary_type = "medley" if attributes.include? "medley"
          @data[:work] = work_rel["work"]["title"]
          @data[:work_url] = get_mb_url("work", work_rel["work"]["id"])
        end

        types << primary_type
        @data[:type] = format_type(types)

        return @data
      end

      def format_type(types)
        result = types.join(" ")
        result[0] = result[0].capitalize
        return result
      end

      def format_duration
        length = Integer(raw["length"]) rescue nil
        if length
          length /= 1000
          return "%02d:%02d" % [length / 60, length % 60]
        end
      end

    end
  end
end
