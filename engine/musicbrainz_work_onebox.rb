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
          writers: written_by
        }

        @data[:type] = "Work" if @data[:type].to_s.empty?

        disambiguation

        return @data
      end

      def written_by
        writers = get_relations(
          "artist", ["writer", "lyricist", "composer", "librettist"], "backward")

        return nil if writers.empty?

        join_sentence(writers.map { |rel| rel["artist"]["name"] })
      end

      def join_sentence(arr, limit=5, limit_phrase="others")
        arr = arr.uniq
        if arr.length == 1
          return arr[0]
        elsif arr.length > limit
          arr = arr[0..limit-2].push(limit_phrase)
        end
        return "#{arr[0..-2].join(', ')} and #{arr.last}"
      end

    end
  end
end
