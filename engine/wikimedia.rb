module Onebox
  module Engine
    module Wikimedia
      private

      URL_REGEX = /^https?:\/\/commons\.wikimedia\.org\/wiki\/(?<name>File:.+)/

      def image_api_url(url)
        "https://en.wikipedia.org/w/api.php?action=query&titles=#{image_name(url)}&prop=imageinfo&iilimit=50&iiprop=timestamp|user|url&iiurlwidth=500&format=json"
      end

      def image_url(url)
        begin
          api_url = image_api_url(url)
          result ||= ::MultiJson.load(open(api_url, read_timeout: timeout))
          pages = result["query"]["pages"]
          return pages.first[1]["imageinfo"].first["url"]
        rescue
          return nil
        end
      end

      def image_name(url)
        match ||= url.match(URL_REGEX)
        return match[:name]
      end
    end
  end
end
