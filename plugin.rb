# name: musicbrainz-onebox
# about: OneBox preview for MusicBrainz.org
# version: 0.1.0
# authors: Philipp Wolfer <ph.wolfer@gmail.com>

require_relative 'engine/musicbrainz_artist_onebox'
require_relative 'engine/musicbrainz_release_onebox'

Onebox.options.load_paths.push(File.join(File.dirname(__FILE__), "templates"))
