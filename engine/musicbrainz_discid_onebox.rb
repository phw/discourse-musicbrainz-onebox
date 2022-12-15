require_relative 'musicbrainz'

module Onebox
  module Engine
    class MusicBrainzDiscIdOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz

      matches_regexp(/^https?:\/\/(?<domain>(?:beta\.)?musicbrainz\.org)\/cdtoc\/(?<discid>[0-9A-Za-z-_.]+)/)
      always_https

      private

      def url
        "https://#{match[:domain]}/ws/2/discid/#{match[:discid]}?fmt=json"
      end

      def match
        @match ||= @url.match(@@matcher)
      end

      def data
        return @data if @data

        @data = {
          link: @url,
          id: raw["id"],
        }

        @data["tracks"] = raw["offsets"].each_with_index.map do |s, i|
          s_next = raw["offsets"][i+1] || raw["sectors"]
          length = s_next - s
          {
            track: i + 1,
            start_sector: s,
            start_time: format_as_time(s),
            length_sector: length,
            length_time: format_as_time(length),
            end_sector: s_next,
            end_time: format_as_time(s_next),
          }
        end if raw["offsets"]

        return @data
      end

      def format_as_time(sectors)
        seconds = (sectors.to_f / 75).round
        format_seconds(seconds)
      end
    end
  end
end
