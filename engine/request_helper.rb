module Onebox
  module Mixins
    module JsonRequestHelper
      def request_json(url)
        ::MultiJson.load(URI.open(url,
          "User-Agent" => "discourse-musicbrainz-onebox",
          :read_timeout => timeout
          ))
      end
    end
  end
end
