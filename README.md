# Podcast

Podcast is a RSS based app. It fetches episodes from the publisher's
website directly with no dependencies on services from Apple or Spotify. 

To search RSS feeds, you can use [Podcast Index][podcastindex] or you can
simply browse the web and find the RSS feed page from the publishers. 

# Features

- You can download episodes on your device and listen to it later without
spending mobile data.

# [Screenshots][screenshots]

# Todo

- refactor web_view logic using js
- refactor exception handling for better diagnostics

# Issues

## AGP version 8.6 and 8.6 bugs
Android Gradle Plugin (AGP) versions 8.6 and 8.7 contain a bug that affects
ExoPlayer in release mode. To avoid this, AGP version is set to 8.5.2 in
`settings.gradle.kts`. 
Check this [issue][agp_issue]
and this [SO article][so_agp_issue]


[podcastindex]: https://podcastindex.org/
[screenshots]: screenshots
[agp_issue]: https://github.com/ryanheise/just_audio/issues/1468
[so_agp_issue]: https://stackoverflow.com/questions/79616421/problems-with-playlist-not-loading-in-just-audio-app