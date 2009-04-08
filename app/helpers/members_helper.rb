module MembersHelper

  def member_search_result(members)
    return unless members
    items = members.map { |m| content_tag("li",h(m.first_name + ' ' + m.last_name)) }
    content_tag("ul", items)
  end

  def hcard(member)
    result = ''
    content_tag("div", :id => member.full_name, :class => "vcard", :style => "display:none") do
      result += image_tag(url_for_file_column(member, :image), :class => "photo", :rel => "me") if member.image if member.image
      result += content_tag("span", :class => "fn n") do
        sub = ''
        sub += content_tag("span", member.first_name, :class=>"given-name") if member.first_name
        sub += content_tag("span", member.last_name, :class=>"family-name") if member.last_name
      end
      result += content_tag("a", :href => h(member.url), :rel => "me") if member.url
      result += content_tag("a", :href => "http://twitter.com/#{member.twitter}") if member.twitter
      result += content_tag("a", :href => "http://github.com/#{member.github}") if member.github
      result += content_tag("span", member.bio.slice(0,150), :class => 'note') if member.bio
      role = (member.occupation_id ? ["Designer", "Manager", "Developer"][member.occupation_id] : "")
      result += content_tag("span", role, :class => 'role')
    end
  end
end
