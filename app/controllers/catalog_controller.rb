# frozen_string_literal: true
class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller

  include Blacklight::Catalog
  include Blacklight::Marc::Catalog

  ## PV: remove sms and cite
  CatalogController.blacklight_config.show.document_actions.delete(:sms)
  CatalogController.blacklight_config.show.document_actions.delete(:citation)
  CatalogController.blacklight_config.show.document_actions.delete(:email)

  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'edismax'
    #config.advanced_search[:form_facet_partial] ||= 'advanced_search_facets_as_select'
    config.advanced_search[:form_solr_parameters] ||= {
        "f.instrument_sm.facet.limit" => -1,
        "f.instrument_sm.facet.sort" => "index",
        "f.author_sm.facet.limit" => -1,
        "f.author_sm.facet.sort" => "index"
    }

    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
        rows: 10
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    config.default_document_solr_params = {
        qt: 'document',
        #  ## These are hard-coded in the blacklight 'document' requestHandler
        fl: '*',
        rows: 1,
        q: '{!term f=id v=$id}'
    }

    # solr field configuration for search results/index views
    config.index.title_field = 'title_s'
    #config.index.display_type_field = 'cu_sm'
    #config.index.thumbnail_field = 'thumbnail_path_ss'

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'
    #config.show.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    # PV this was a test for a combined field
    #config.add_facet_field 'loh_sm', label: 'Level of Health', sort: 'index', solr_params: {'facet.mincount' => 0}

    #config.add_facet_field 'example_pivot_field', label: 'Pivot Field', :pivot => ['fs_sm', 'ss_sm']

    config.add_facet_field 'bpv_sm', label: 'Biological and physiological variables', sort: 'index', solr_params: {'facet.mincount' => 0}
    config.add_facet_field 'ss_sm', label: 'Symptom status', sort: 'index', solr_params: {'facet.mincount' => 0}
    config.add_facet_field 'fs_sm', label: 'Functional status', sort: 'index', solr_params: {'facet.mincount' => 0}

    #config.add_facet_field 'a_pivot_facet', pivot: ['ss_sm', 'fs_sm']

    config.add_facet_field 'ghp_sm', label: 'General health perceptions / HRQoL', sort: 'index', solr_params: {'facet.mincount' => 0}
    config.add_facet_field 'oql_sm', label: 'Overall quality of life', sort: 'index', solr_params: {'facet.mincount' => 0}
    config.add_facet_field 'age_sm', label: 'Age', sort: 'index', solr_params: {'facet.mincount' => 0}
    config.add_facet_field 'disease_sm', label: 'Disease', limit: 23, sort: 'index', solr_params: {'facet.mincount' => 0}
    config.add_facet_field 'pnp_sm', label: 'PRO / non-PRO', sort: 'index', solr_params: {'facet.mincount' => 0}
    #config.add_facet_field 'hr_sm', label: 'Health related', sort: 'index'
    config.add_facet_field 'tmi_sm', label: 'Type of measurement instrument', sort: 'index', solr_params: {'facet.mincount' => 0}
    #config.add_facet_field 'pm_sm', label: 'Purpose of measurement', sort: 'index'
    #config.add_facet_field 'mp_sm', label: 'Measurement properties', sort: 'index'
    #config.add_facet_field 'fa_sm', label: 'Feasibility aspects', sort: 'index'
    #config.add_facet_field 'is_sm', label: 'Interpretability aspects', sort: 'index'
    #config.add_facet_field 'cu_sm', label: 'COSMIN used', sort: 'index'
    config.add_facet_field 'instrument_sm', label: 'Instrument', sort: 'count', limit: 10, index_range: 'A'..'Z'
    config.add_facet_field 'author_sm', label: 'Author', sort: 'count', limit: 10, index_range: 'A'..'Z'


    #config.add_facet_field 'example_query_facet_field', label: 'Publish Date', :query => {
    #   :years_5 => { label: 'within 5 Years', fq: "pub_date:[#{Time.zone.now.year - 5 } TO *]" },
    #   :years_10 => { label: 'within 10 Years', fq: "pub_date:[#{Time.zone.now.year - 10 } TO *]" },
    #   :years_25 => { label: 'within 25 Years', fq: "pub_date:[#{Time.zone.now.year - 25 } TO *]" }
    #}


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    #config.add_index_field 'title_s', label: 'Title'
    config.add_index_field 'author_sm', label: 'Author'
    config.add_index_field 'pubyear_s', label: 'Publication year'
    config.add_index_field 'doi_s', label: 'DOI', :helper_method => :doi_link_helper

    config.index.respond_to.csv = true
    config.index.respond_to.docx = true

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    #config.add_show_field 'title_s', label: 'Title'
    config.add_show_field 'author_sm', label: 'Authors', :link_to_search => true
    config.add_show_field 'abstract_s', label: 'Abstract', :helper_method => :abstract_show_helper
    config.add_show_field 'doi_s', label: 'DOI', :helper_method => :doi_link_helper
    config.add_show_field 'url_sm', label: 'URL', :helper_method => :url_link_helper
    config.add_show_field 'journal_s', label: 'Journal'
    config.add_show_field 'issn_s', label: 'issn'
    config.add_show_field 'pubyear_s', label: 'Publication year'
    config.add_show_field 'startpage_s', label: 'pages'
    config.add_show_field 'bpv_sm', label: 'Biological and physiological variables', :link_to_search => true, :separator_options => {words_connector: '<br>', last_word_connector: '<br>', two_words_connector: '<br>'}
    config.add_show_field 'ss_sm', label: 'Symptom status', :link_to_search => true, :separator_options => {words_connector: '<br>', last_word_connector: '<br>', two_words_connector: '<br>'}
    config.add_show_field 'fs_sm', label: 'Functional status', :link_to_search => true, :separator_options => {words_connector: '<br>', last_word_connector: '<br>', two_words_connector: '<br>'}
    config.add_show_field 'ghp_sm', label: 'General health perceptions / HRQoL', :link_to_search => true, :separator_options => {words_connector: '<br>', last_word_connector: '<br>', two_words_connector: '<br>'}
    config.add_show_field 'oql_sm', label: 'Overall quality of life', :link_to_search => true, :separator_options => {words_connector: '<br>', last_word_connector: '<br>', two_words_connector: '<br>'}
    config.add_show_field 'age_sm', label: 'Age', :link_to_search => true, :separator_options => {words_connector: '<br>', last_word_connector: '<br>', two_words_connector: '<br>'}
    config.add_show_field 'disease_sm', label: 'Disease', :link_to_search => true, :separator_options => {words_connector: '<br>', last_word_connector: '<br>', two_words_connector: '<br>'}
    config.add_show_field 'pnp_sm', label: 'PRO / non-PRO', :link_to_search => true, :separator_options => {words_connector: '<br>', last_word_connector: '<br>', two_words_connector: '<br>'}
    config.add_show_field 'tmi_sm', label: 'Type of measurement instrument', :link_to_search => true, :separator_options => {words_connector: '<br>', last_word_connector: '<br>', two_words_connector: '<br>'}
    config.add_show_field 'cu_sm', label: 'COSMIN used', :link_to_search => true, :separator_options => {words_connector: '<br>', last_word_connector: '<br>', two_words_connector: '<br>'}
    config.add_show_field 'instrumentpresentation_sfm', label: 'Instrument', :helper_method => :instrument_presentation_helper


    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields', label: 'All Fields'

    config.add_search_field('author_sm', label: 'Author') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = {
          qf: "'${author_qf}'",
          pf: "'${author_pf}'"
      }
    end

    config.add_search_field('instrument_sm', label: 'Instrument') do |field|
      field.solr_parameters = {
          qf: "'${instrument_qf}'",
          pf: "'${instrument_pf}'"
      }
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = {
          'spellcheck.dictionary': 'title',
          qf: "'${title_qf}'",
          pf: "'${title_pf}'"
      }
    end

    # Add it to solr schema first
    # config.add_search_field('author') do |field|
    #  field.solr_parameters = {
    #      'spellcheck.dictionary': 'author',
    #      qf: '${author_qf}',
    #      pf: '${author_pf}'
    #  }
    #end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    #config.add_search_field('subject') do |field|
    #  field.qt = 'search'
    #  field.solr_parameters = {
    #    'spellcheck.dictionary': 'subject',
    #    qf: '${subject_qf}',
    #    pf: '${subject_pf}'
    #  }
    #end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, title_sort asc', label: 'relevance'
    #config.add_sort_field 'title_sort asc', label: 'title'
    config.add_sort_field 'author_sort asc, title_sort asc', label: 'first author'
    config.add_sort_field 'pub_date_sort asc, title_sort asc', label: 'publication date (ascending)'
    config.add_sort_field 'pub_date_sort desc, title_sort asc', label: 'publication date (descending)'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
  end
end
