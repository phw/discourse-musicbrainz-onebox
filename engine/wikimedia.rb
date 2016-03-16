module Onebox
  module Engine
    module Wikimedia
      private

      URL_REGEX = /^https?:\/\/commons\.wikimedia\.org\/wiki\/(?<name>File:.+)/

      def image_api_url(name)
        "https://en.wikipedia.org/w/api.php?action=query&titles=#{name}&prop=imageinfo&iilimit=50&iiprop=timestamp|user|url&iiurlwidth=500&format=json"
      end

      def image_url(url)
        return nil if !SiteSetting.musicbrainz_load_wikimedia_images
        begin
          name = image_name(url)
          return nil if name.nil?
          api_url = image_api_url(name)
          result ||= ::MultiJson.load(open(api_url, read_timeout: timeout))
          pages = result["query"]["pages"]
          return pages.first[1]["imageinfo"].first["url"]
        rescue
          return nil
        end
      end

      def image_name(url)
        match ||= url.match(URL_REGEX)
        return match[:name] if match
      end
    end
  end
end
