# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr, :escape_lonely_hyphen]

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end

  def escape_lonely_hyphen(solr_parameters)
    solr_parameters[:q] ||= ''
    if solr_parameters[:q].match(/".*\s-\s.*"/).nil?
      solr_parameters[:q] = solr_parameters[:q].gsub(/\s-\s/, " ")
    end
  end
end