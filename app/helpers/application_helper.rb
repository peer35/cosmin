module ApplicationHelper
  require 'uri'
  def abstract_show_helper args
    args[:document][args[:field]].gsub(/(([A-Z]{2,}|\s)+):/, '<br><br><b>\1:</b>').gsub(/^<br><br>/, '').html_safe
  end

  def doi_link_helper args
    link_to(args[:document][args[:field]], 'https://dx.doi.org/' + args[:document][args[:field]], target: "_blank")
  end

  def url_link_helper args
    urls = []
    args[:document][args[:field]].each do |url|
      if url =~ /\Ahttp/
        url = link_to(url, url, target: "_blank")
      else
        url.gsub! '<', '&lt'
        url.gsub! '>', '&gt'
      end
      urls.append(url)
    end
    urls.join('<br>').html_safe
  end

  require 'json'

  def instrument_presentation_helper args
    html = ''
    args[:document][args[:field]].each do |json_string|
      logger.debug json_string
      o = JSON.parse(json_string)
      html = html + facet_link('instrument_sm', o['name'])
      url_list = []
      unless o['url1'].nil? || o['url1'] == ''
        #url_list.append(link_to('proqolid', o['url1'], target: "_blank"))
        url_list.append(link_to(image_tag('proqolid-blue.png', height: '14'), o['url1'], target: "_blank"))
      end
      unless o['url2'].nil? || o['url2'] == ''
        url_list.append(link_to(image_tag('LogoZUYD.png', height: "14"), o['url2'], target: "_blank"))
      end
      unless o['url3'].nil? || o['url3'] == ''
        uri = URI.parse(o['url3'])
        url_list.append('also see: ' + link_to(uri.host, o['url3'], target: "_blank"))
      end
      unless url_list.count == 0
        html = html + '&nbsp;&nbsp;&nbsp;'
        html = html + url_list.join('&nbsp;|&nbsp;')
        #html = html + ']'
      end
      html = html + '<br>'
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

# monkeypatched to allow merging of url params
module AlphabeticalPaginate
  module ViewHelpers
    def alphabetical_paginate_patch(options = {})
      output = ""
      links = ""
      output += javascript_include_tag 'alphabetical_paginate' if options[:js] == true
      logger.debug options
      options[:scope] ||= main_app

      if options[:paginate_all]
        range = options[:language].letters_range
        if options[:others]
          range += ["*"]
        end
        if options[:enumerate] && options[:numbers]
          range = (0..9).to_a.map {|x| x.to_s} + range
        elsif options[:numbers]
          range = ["0-9"] + range
        end
        range.unshift "All" if (options[:include_all] && !range.include?("All"))
        range.each do |l|
          link_letter = l
          if options[:slugged_link] && (l =~ options[:language].letters_regexp || l == "All")
            link_letter = options[:language].slugged_letters[l]
          end
          letter_options = {letter: link_letter}
          if !options[:all_as_link] && (l == "All")
            letter_options[:letter] = nil
          end
          logger.debug letter_options
          letter_options.merge(options[:merge_params])
          logger.debug letter_options
          url = options[:scope].url_for(letter_options)
          value = options[:language].output_letter(l)
          if l == options[:currentField]
            links += content_tag(:li, link_to(value, "#", "data-letter" => l), :class => "active")
          elsif options[:db_mode] or options[:availableLetters].include? l
            links += content_tag(:li, link_to(value, url, "data-letter" => l))
          else
            links += content_tag(:li, link_to(value, url, "data-letter" => l), :class => "disabled")
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
        options[:availableLetters] -= (1..9).to_a.map {|x| x.to_s} if !options[:numbers]
        options[:availableLetters] -= ["*"] if !options[:others]

        options[:availableLetters].each do |l|
          link_letter = l
          if options[:slugged_link] && (l =~ options[:language].letters_regexp || l == "All")
            link_letter = options[:language].slugged_letters[l]
          end
          letter_options = {letter: link_letter}
          if !options[:all_as_link] && (l == "All")
            letter_options[:letter] = nil
          end
          logger.debug options[:merge_params]
          logger.debug letter_options
          letter_options = letter_options.merge(options[:merge_params])
          logger.debug letter_options

          url = options[:scope].url_for(letter_options)
          value = options[:language].output_letter(l)
          links += content_tag(:li, link_to(value, url, "data-letter" => l), :class => ("active" if l == options[:currentField]))
        end
      end

      element = options[:bootstrap3] ? 'ul' : 'div'
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

