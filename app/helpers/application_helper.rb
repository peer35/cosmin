module ApplicationHelper
  require "uri"

  def abstract_show_helper(args)
    args[:document][args[:field]].gsub(/(([A-Z]{2,}|\s)+):/, '<br><br><b>\1:</b>').gsub(/^<br><br>/, "").html_safe
  end

  def doi_link_helper(args)
    link_to(args[:document][args[:field]], "https://dx.doi.org/" + args[:document][args[:field]], target: "_blank")
  end

  def url_link_helper(args)
    urls = []
    args[:document][args[:field]].each do |url|
      if url =~ /\Ahttp/
        url = link_to(url, url, target: "_blank")
      else
        url.gsub! "<", "&lt"
        url.gsub! ">", "&gt"
      end
      urls.append(url)
    end
    urls.join("<br>").html_safe
  end

  require "json"

  def instrument_presentation_helper(args)
    html = ""
    args[:document][args[:field]].each do |json_string|
      logger.debug json_string
      o = JSON.parse(json_string)
      html = html + facet_link("instrument_sm", o["name"])
      url_list = []
      unless o["url1"].nil? || o["url1"] == ""
        #url_list.append(link_to('proqolid', o['url1'], target: "_blank"))
        url_list.append(link_to(image_tag("proqolid-blue-crop.png", height: "14"), o["url1"], target: "_blank"))
      end
      unless o["url2"].nil? || o["url2"] == ""
        url_list.append(link_to(image_tag("LogoZUYD.png", height: "14"), o["url2"], target: "_blank"))
      end
      unless o["url3"].nil? || o["url3"] == ""
        uri = URI.parse(o["url3"])
        url_list.append("also see: " + link_to(uri.host, o["url3"], target: "_blank"))
      end
      unless url_list.count == 0
        html = html + "&nbsp;&nbsp;&nbsp;"
        html = html + url_list.join("&nbsp;|&nbsp;")
        #html = html + ']'
      end
      html = html + "<br>"
    end
    html.html_safe
  end

  def facet_link(field, v)
    link_to v, search_path(field, v)
  end

  def search_path(field, v)
    params = h_facet_params(field, v)
    search_action_path(params)
  end

  def h_facet_params(field, v)
    search_state.reset.add_facet_params(field, v)
  end
end

module AlphabeticalPaginate
  # Monkey patch needed because find_each changed in Ruby 6
  module ControllerHelpers
    def alpha_paginate(current_field, params = { enumerate: false, default_field: "a",
                                                 paginate_all: false, numbers: true,
                                                 others: true, pagination_class: "pagination-centered",
                                                 batch_size: 500, db_mode: false,
                                                 db_field: "id", include_all: true,
                                                 js: true, support_language: :en,
                                                 bootstrap3: false, slugged_link: false,
                                                 slug_field: "slug", all_as_link: true })
      params[:default_field] ||= "a"
      params[:paginate_all] ||= false
      params[:support_language] ||= :en
      params[:language] = AlphabeticalPaginate::Language.new(params[:support_language])
      params[:include_all] = true if !params.has_key? :include_all
      params[:numbers] = true if !params.has_key? :numbers
      params[:others] = true if !params.has_key? :others
      params[:js] = true if !params.has_key? :js
      params[:pagination_class] ||= "pagination-centered"
      params[:batch_size] ||= 500
      params[:db_mode] ||= false
      params[:db_field] ||= "id"
      params[:slugged_link] ||= false
      params[:slugged_link] = params[:slugged_link] && defined?(Babosa)
      params[:slug_field] ||= "slug"
      params[:all_as_link] = true if !params.has_key? :all_as_link

      output = []

      if params[:db_mode]
        letters = nil
        if !params[:paginate_all]
          letters = filter_by_cardinality(find_available_letters(params[:db_field]))
          set_default_field letters, params
        end
        params[:availableLetters] = letters.nil? ? [] : letters
      end

      if params[:include_all]
        current_field ||= "all"
        all = current_field == "all"
      end

      current_field ||= params[:default_field]
      current_field = current_field.mb_chars.downcase.to_s
      all = params[:include_all] && current_field == "all"

      if params[:db_mode]
        if !ActiveRecord::Base.connection.adapter_name.downcase.include? "mysql"
          raise "You need a mysql database to use db_mode with alphabetical_paginate"
        end

        if all
          output = self
        else

          # In this case we can speed up the search taking advantage of the indices
          can_go_quicker = (current_field =~ params[:language].letters_regexp) || (current_field =~ /[0-9]/ && params[:enumerate])

          # Use LIKE the most as you can to take advantage of indeces on the field when available
          # REGEXP runs always a full scan of the table!
          # For more information about LIKE and indeces have a look at
          # http://myitforum.com/cs2/blogs/jnelson/archive/2007/11/16/108354.aspx

          # Also use some sanitization from ActiveRecord for the current field passed
          if can_go_quicker
            output = self.where("LOWER(%s) LIKE ?" % params[:db_field], current_field + "%")
          else
            regexp_to_check = current_field =~ /[0-9]/ ? "^[0-9]" : "^[^a-z0-9]"
            output = self.where("LOWER(%s) REGEXP '%s.*'" % [params[:db_field], regexp_to_check])
          end
        end
      else
        availableLetters = {}
        # Monkey patch needed because find_each changed in Ruby 6
        self.find_each(batch_size: params[:batch_size]) do |x|
          slug = eval("x.#{params[:slug_field]}") if params[:slugged_link]

          field_val = block_given? ? yield(x).to_s : x.id.to_s
          field_letter = field_val[0].mb_chars.downcase.to_s

          case field_letter
          when params[:language].letters_regexp
            availableLetters[field_letter] = true if !availableLetters.has_key? field_letter
            regexp = params[:slugged_link] ? params[:language].slugged_regexp : params[:language].letters_regexp
            field = params[:slugged_link] ? slug : field_letter
            output << x if all || (current_field =~ regexp && current_field == field)
          when /[0-9]/
            if params[:enumerate]
              availableLetters[field_letter] = true if !availableLetters.has_key? field_letter
              output << x if all || (current_field =~ /[0-9]/ && field_letter == current_field)
            else
              availableLetters["0-9"] = true if !availableLetters.has_key? "numbers"
              output << x if all || current_field == "0-9"
            end
          else
            availableLetters["*"] = true if !availableLetters.has_key? "other"
            output << x if all || current_field == "*"
          end
        end
        params[:availableLetters] = availableLetters.collect { |k, v| k.mb_chars.capitalize.to_s }
        output.sort! { |x, y| block_given? ? (yield(x).to_s <=> yield(y).to_s) : (x.id.to_s <=> y.id.to_s) }
      end
      params[:currentField] = current_field.mb_chars.capitalize.to_s
      return ((params[:db_mode] && params[:db_field]) ? output.order("#{params[:db_field]} ASC") : output), params
    end
  end

  module ViewHelpers
    # Monkeypatched to fix page links for bootstrap 4
    def alphabetical_paginate(options = {})
      output = ""
      links = ""
      output += javascript_include_tag "alphabetical_paginate" if options[:js] == true
      options[:scope] ||= main_app

      if options[:paginate_all]
        range = options[:language].letters_range
        if options[:others]
          range += ["*"]
        end
        if options[:enumerate] && options[:numbers]
          range = (0..9).to_a.map { |x| x.to_s } + range
        elsif options[:numbers]
          range = ["0-9"] + range
        end
        range.unshift "All" if (options[:include_all] && !range.include?("All"))
        range.each do |l|
          link_letter = l
          if options[:slugged_link] && (l =~ options[:language].letters_regexp || l == "All")
            link_letter = options[:language].slugged_letters[l]
          end
          letter_options = { letter: link_letter }
          if !options[:all_as_link] && (l == "All")
            letter_options[:letter] = nil
          end

          url = options[:scope].url_for(letter_options)
          value = options[:language].output_letter(l)
          if l == options[:currentField]
            links += content_tag(:li, link_to(value, "#", "data-letter" => l, class: "page-link"), :class => "active page-item")
          elsif options[:db_mode] or options[:availableLetters].include? l
            links += content_tag(:li, link_to(value, url, "data-letter" => l, class: "page-link"), :class => "page-item")
          else
            links += content_tag(:li, link_to(value, url, "data-letter" => l, class: "page-link"), :class => "disabled page-item")
          end
        end
      else
        options[:availableLetters].sort!
        options[:availableLetters] = options[:availableLetters][1..-1] + ["*"] if options[:availableLetters][0] == "*"
        #Ensure that "All" is always at the front of the array
        if options[:include_all]
          options[:availableLetters].delete("All") if options[:availableLetters].include?("All")
          options[:availableLetters].unshift("All")
        end
        options[:availableLetters] -= (1..9).to_a.map { |x| x.to_s } if !options[:numbers]
        options[:availableLetters] -= ["*"] if !options[:others]

        options[:availableLetters].each do |l|
          link_letter = l
          if options[:slugged_link] && (l =~ options[:language].letters_regexp || l == "All")
            link_letter = options[:language].slugged_letters[l]
          end
          letter_options = { letter: link_letter }
          if !options[:all_as_link] && (l == "All")
            letter_options[:letter] = nil
          end

          url = options[:scope].url_for(letter_options)
          value = options[:language].output_letter(l)
          links += content_tag(:li, link_to(value, url, "data-letter" => l), :class => ("active" if l == options[:currentField]))
        end
      end

      element = options[:bootstrap3] ? "ul" : "div"
      if options[:pagination_class] != "none"
        pagination = "<#{element} class='pagination %s alpha' style='height:35px;'>" % options[:pagination_class]
      else
        pagination = "<#{element} class='pagination alpha' style='height:35px;'>"
      end
      pagination +=
        (options[:bootstrap3] ? "" : "<ul>") +
        links +
        (options[:bootstrap3] ? "" : "</ul>") +
        "</#{element}>"

      output += pagination
      output.html_safe
    end
  end
end
