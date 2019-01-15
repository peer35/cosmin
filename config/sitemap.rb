# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://database.cosmin.nl"

SitemapGenerator::Sitemap.create do
  # We set a boolean value in our environment files to prevent generation in staging or development
  #break unless Rails.application.config.sitemap[:generate]

  # Add single record pages
  cursorMark = '*'
  solr = RSolr.connect :url => 'http://127.0.0.1:8983/solr/cosmin'

  loop do
    response = solr.get('select', :params => { # you may need to change the request handler
                                                                           'q'          => '*:*', # all docs
                                                                           'fl'         => 'id', # we only need the ids
                                                                           'fq'         => '', # optional filter query
                                                                           'cursorMark' => cursorMark, # we need to use the cursor mark to handle paging
                                                                           'rows'       => 1000,
                                                                           'sort'       => 'id asc'
    })

    response['response']['docs'].each do |doc|
      add "/catalog/#{doc['id']}"
    end

    break if response['nextCursorMark'] == cursorMark # this means the result set is finished

    cursorMark = response['nextCursorMark']
  end
end