# 0.15.2 - 2025-02-17
- Fixed external link icon size for newer Discourse
- Fixed external link icon order for label onebox

# 0.15.1 - 2023-02-02
- Fixed cover art stylesheet for Discourse 3.1

# 0.15 - 2023-01-31
- Added ListenBrainz link for releases and recordings
- Consistent ordering of external link icons
- Use SVG icon for CritiqueBrainz

# 0.14 - 2023-01-28
- Added separate setting `musicbrainz_enabled` to enable / disable this plugin

# 0.13.1 - 2023-01-16
- Fixed display size of external link icons

# 0.13 - 2023-01-09
- Public collections onebox

# 0.12 - 2022-12-17
- Load release group image for releases without cover art
- Load Wikidata data from release group if missing in release
- Render track counts on releases with thousands separator
- Area onebox
- Fixed loading Wikimedia images with non-ASCII characters in file name

# 0.11.1 - 2022-12-15
- Fixed selection of first Wikimedia Commons picture
- Fixed loading release group images from CAA
- Fixed loading Wikipedia link for release groups, releases and recordings
- Fixed life-span formatting with end date
- Fixed minor formatting issue in event template

# 0.11 - 2022-12-15
- Show instrument description
- Updated settings description texts and translations

# 0.10.0 - 2022-12-14
- Show total track count for releases
- Show parent work for works
- Add some margin between external links and text content

# 0.9.0 - 2022-12-13
- CritiqueBrainz links for recordings
- Show Wikipedia link for all entities, if available
- Removed AcousticBrainz link (#18)
- Show genres for artists, labels, release groups, releases and recordings
- Show medium details for releases

# 0.8.0 - 2022-12-12
- Show link to release group on CritiqueBrainz in release onebox (#17)
- CritiqueBrainz links for labels and works (#17)
- DiscID onebox (#12)
- Series onebox (#11)
- Instrument onebox
- Use Wikidata to load images, if loading images from Wikimedia is activated
- Updated admin UI translation for Norwegian Bokmål

# 0.7.0 - 2021-10-18
- Fixed display of label logos
- Indicate image source (CAA, Wikimedia or source domain)
- Images are linked to their sources
- Show recording duration (#14)
- Added options to enable/disable loading images from CAA and loading
  images from other sources (e.g. label logos)
- Prevent unnecessary linebreak in event box
- Fix deprecation warning about using `open` to load HTTP resources
- Translations for admin UI labels into German and Norwegian Bokmål

# 0.6.0 - 2018-08-31
- Do not onebox edit and history links (#8)
- Check if release group cover art exists (#6)
- Add CritiqueBrainz link for Release Groups, Artists, Events, Places (#5)
- Add AcousticBrainz link for Recordings (#4)
- Fix life-span not being displayed
- Fix artist description always empty

# 0.5.0 - 2017-10-09
- Set custom user agent to prevent rate limit blocking (#10)
- Prevent dangling commas in artist description (#9)
- Events: Show performers only if available
- Fixed favicon asset loading

# 0.4.0 - 2016-03-21
- MusicBrainz event onebox

# 0.3.0 - 2016-03-16
- MusicBrainz recording onebox
- MusicBrainz place onebox
- Configuration option to disable Wikimedia image loading

# 0.2.0 - 2016-03-16
- MusicBrainz work onebox
- MusicBrainz label onebox
- Load Wikimedia images for artists and labels
- Display release status for releases
- Limit the number of writers displayed for works
- Use original URL domain for API requests
- Styling improvements

# 0.1.1 - 2016-03-16
Show MusicBrainz favicon in onebox

# 0.1.0 - 2016-03-15
Initial release with basic support for artists, release groups and releases.
