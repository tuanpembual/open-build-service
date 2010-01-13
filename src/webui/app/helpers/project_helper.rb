module ProjectHelper
  def format_target_list( project )
    result = ""
    result += "<ul>\n"
    if @project.has_element? :target
      @project.each_target do |target|
        result += "<li><b>#{target.platform.name}</b>\n"
        result += format_arch_list( target )
        result += "</li>\n"
      end
    end
    result += "</ul>\n"
  end

  def format_arch_list( target )
    result = ""
    if target.has_element? :arch
      result += "<ul>\n"
      target.each_arch do |arch|
        result += "<li>#{arch}</li>\n"
      end
      result += "</ul>\n"
    end
  end

  def repo_status_for( repo, arch )
    @repostatushash[repo][arch] || ActiveXML::XMLNode.new("<status code='-'/>")
  end

  def status_for( repo, arch, package )
    @statushash[repo][arch][package] || ActiveXML::XMLNode.new("<status code='-' package='#{package}'/>")
  end

  def status_id_for( repo, arch, package )
    "#{package}:#{repo}:#{arch}"
  end

  def watch_link_text
    user.watches?(@project.name) ? "[Don't watch this project]" : "[Watch this project]"
  end

  def format_packstatus_for( repo, arch )
    return if @buildresult.nil?
    return unless @buildresult.has_element? :result
    ret = String.new
    
    result = @buildresult.result("@repository='#{repo}' and @arch='#{arch}'")
    if result.nil?
      ret << "n/a<br>"
    else
      if result.has_attribute? "state"
        if result.has_attribute? "dirty"
          ret << "State: outdated(" << result.state << ")"
        else
          ret << "State: " << result.state
        end
        ret << "<br>"
      end
      result.summary.each_statuscount do |scnt|
        ret << link_to("#{scnt.code}:&nbsp;#{scnt.count}", :action => :monitor, 'repo_' + repo => 1, 'arch_' + arch => 1, :project => params[:project], scnt.code => 1, :defaults => 0)
        ret << "<br>\n"
      end
    end

    return ret
  end

  def simple_repo_button_to( label, opt={} )
    reponame = String.new
    reponame << BASE_NAMESPACE << ":" if BASE_NAMESPACE
    reponame << opt[:repo]

    defaults = {
      :arch => [],
      :project => @project,
      :action => :save_target
    }
    opt = defaults.merge opt

    btn_to_opt = {
      :targetname => opt[:reponame],
      :platform => reponame,
      :project => opt[:project],
      :action => opt[:action]
    }

    opt[:arch].each do |arch|
      btn_to_opt["arch[#{arch}]"] = ""
    end

    if @project and @project.has_element?("repository[@name='#{opt[:reponame]}']")
      return button_to(label, btn_to_opt, {:disabled => true})
    else
      return button_to(label, btn_to_opt)
    end
  end

  def draggable_repo( label, opt={} )
    out = String.new
    out << "<li id='repo_#{label}' class='draggable_sub_element'>#{label}</li>"
    out << draggable_element("repo_#{label}", :revert => true, :snap => true,
             :reverteffect => "function(element, top_offset, left_offset) {
               new Effect.Move( element, {x: -left_offset, y: -top_offset, duration: 0})
             }")
    out
  end
end
