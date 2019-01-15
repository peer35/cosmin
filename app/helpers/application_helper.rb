module ApplicationHelper
  def abstract_show_helper args
    args[:document][args[:field]].gsub(/(([A-Z]{2,}|\s)+):/, '<br><br><b>\1:</b>').gsub(/^<br><br>/, '').html_safe
  end

  def doi_link_helper args
    link_to(args[:document][args[:field]], 'https://dx.doi.org/' + args[:document][args[:field]], target: "_blank")
  end

  def url_link_helper args
    urls=[]
    args[:document][args[:field]].each do |url|
      if url =~ /\Ahttp/
        url=link_to(url, url, target: "_blank")
      else
        url.gsub! '<', '&lt'
        url.gsub! '>', '&gt'
      end
      urls.append(url)
    end
    urls.join('<br>').html_safe
  end

  def break_join_helper args
    args[:document][args[:field]].join('<br>').html_safe
  end

  require 'json'
  def instrument_presentation_helper args
    html=''
    args[:document][args[:field]].each do |json_string|
      logger.debug json_string
      o=JSON.parse(json_string)
      html=html+o['name']
      url_list=[]
      unless o['doi'].nil? || o['doi']==''
        url_list.append('doi: ' + link_to(o['doi'], 'https://dx.doi.org/' + o['doi'], target: "_blank"))
      end
      unless o['pmid'].nil? || o['pmid']==''
        url_list.append(link_to('pubmed', 'https://www.ncbi.nlm.nih.gov/pubmed/' + o['pmid'], target: "_blank"))
      end
      unless o['url1'].nil? || o['url1']==''
        url_list.append(link_to('proqolid', o['url1'], target: "_blank"))
      end
      unless o['url2'].nil? || o['url2']==''
        url_list.append(link_to('other', o['url2'], target: "_blank"))
      end
      unless o['url3'].nil? || o['url3']==''
        url_list.append(link_to('website3', o['url3'], target: "_blank"))
      end
      logger.debug url_list
      unless url_list.count == 0 && (o['reference'].nil? || o['reference']=='')
        html=html+' [see: '
        unless o['reference'].nil? || o['reference']==''
          # <a href="#" data-toggle="popover" title="Popover Header" data-content="Some content inside the popover">Toggle popover</a>
          #ref = link_to('reference', '', { :class => 'reference', 'data-toggle' => 'popover', :title => 'Reference', 'data-content' => o['reference']})
          ref = '<a class="reference" data-toggle="popover" data-placement="bottom" data-content="'+o['reference']+'">reference</a>'
          html=html + ref + ', '
        end
        unless url_list.count == 0
          html=html + url_list.join(', ')
        end
        html=html + ']'
      end
      html=html+'<br>'
    end
    html.html_safe
  end
end
