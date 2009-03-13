module MembersHelper

    def member_search_result(members)
    return unless members
    items = members.map { |m| content_tag("li",h(m.first_name + ' ' + m.last_name)) }
    content_tag("ul", items)
  end
end
