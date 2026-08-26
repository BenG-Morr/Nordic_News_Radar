# Konfigurierte RSS-/Atom-Quellen. Pro Land werden drei Medien verarbeitet.
locals {
  news_feeds = [
    {
      name    = "SVT Nyheter"
      country = "SE"
      url     = "https://www.svt.se/nyheter/rss.xml"
    },
    {
      name    = "Dagens Nyheter"
      country = "SE"
      url     = "https://www.dn.se/rss/"
    },
    {
      name    = "Svenska Dagbladet"
      country = "SE"
      url     = "https://www.svd.se/feed/articles.rss"
    },
    {
      name    = "Yle Uutiset"
      country = "FI"
      url     = "https://feeds.yle.fi/uutiset/v1/majorHeadlines/YLE_UUTISET.rss"
    },
    {
      name    = "Helsingin Sanomat"
      country = "FI"
      url     = "https://www.hs.fi/rss/tuoreimmat.xml"
    },
    {
      name    = "Iltalehti"
      country = "FI"
      url     = "https://www.iltalehti.fi/rss.xml"
    }
  ]
}
