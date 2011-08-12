module DiscussionPostsHelper

  def valid_date
    @discussion.start <= Date.today && Date.today <= @discussion.end
  end
  
  #Renderiza um post na tela de interação do portólio.
  #threaded indica se as respostas deste post devem ser renderizadas com ele.
  def show_post(post = nil, threaded=true)
    post_string = ""
    childs = {}
    editable = false
    childs_count = DiscussionPost.child_count(post.id)
    can_interact=true
    
    can_interact= false unless (valid_date)

    #Um post pode ser editado se é do próprio usuário e se não possui respostas.
    editable = true if (post.user.id == current_user.id) && (childs_count == 0)

    #Recuperando posts filhos para renderização
    childs = DiscussionPost.posts_child(post[:id]) if threaded

    #Tratando nick para exibição
    nick = post.user_nick
    nick = nick.slice(0..12) + '...' if nick.length > 15

    #Recuperando caminho da foto a ser carregada
    photo_url = 'no_image.png'
    photo_url = post.user.photo.url(:medium) if post.photo_file_name


    #Montando exibição do post e exibindo respostas recursivamente
    post_string << '<table border="0" cellpadding="0" cellspacing="0" class="forum_post">'
    post_string <<    '<tr>'
    post_string <<      '<td class="forum_post_head_left">'
    post_string <<        '<span alt="' << post.user_nick << '">' << nick << '</span><br />'
    post_string <<        '<span class="forum_participant_profile" >'<< post.profile << '</span>'
    post_string <<      '</td>'
    post_string <<      '<td class="forum_post_head_right">'
    post_string <<        '<div class="forum_post_date">' << (l post[:updated_at], :format => :discussion_post ) << '</div>'
    post_string <<      '</td>'
    post_string <<    '</tr>'
    post_string <<    '<tr>'
    post_string <<      '<td class="forum_post_content_left">'
    post_string <<        (image_tag photo_url, :alt => t(:mysolar_alt_img_user) + ' ' + post.user_nick)
#    post_string <<        '<div class="forum_participants_icons">'
#    post_string <<        '<span>' << (link_to (image_tag "icon_profile.png", :alt=>t(:icon_profile))) << '</span>'
#    post_string <<        '<span>' << (link_to (image_tag "icon_add_user.png", :alt=>t(:icon_add_participant))) << '</span>'
#    post_string <<        '<span>' << (link_to (image_tag "icon_chat.png", :alt=>t(:icon_chat))) << '</span>'
#    post_string <<        '<span>' << (link_to (image_tag "icon_message_participant.png", :alt=>t(:icon_send_email))) << '</span>'
#    post_string <<        '</div>'
    post_string <<      '</td>'
    post_string <<      '<td class="forum_post_content_right">'
    post_string <<        '<div class="forum_post_inner_content" style="min-height:100px">' << (sanitize post.content) <<' </div>'

    #Apresentando os arquivos do post
    post_string << show_attachments(post, editable, can_interact)
    
    #Exibindo botões de edição, resposta e exclusão
    post_string << show_buttons(editable,can_interact, post)

    post_string <<      '</td>'
    post_string <<    '</tr>'
    post_string <<  '</table>'

    #Renderizando as respostas ao post
    childs.each do |child|
      post_string << '<div class="forum_post_child_ident">' << show_post(child, true) << '</div>'
    end

    return post_string
  end

  #Utilizado na paginação
  def count_discussion_posts(discussion_id = nil, plain_list = true)
    return DiscussionPost.count_discussion_posts(discussion_id, plain_list)
  end

  #Utilizado nas consultas para portlets
  def list_portlet_discussion_posts(offer_id, group_id)
    discussions = Discussion.all_by_offer_id_and_group_id(offer_id, group_id)
    return DiscussionPost.order('updated_at DESC').limit(Rails.application.config.items_per_page.to_i).find_all_by_discussion_id(discussions)
  end
  
  private
  #Link para o lightbox de upload
  def show_attachments(post = nil, editable = false, can_interact = false)
    #Cabeçalho
    form_string =  '<div style="display:table;width:100%;">'
    form_string <<   '<span style="display:table-cell;width:10px;"><b>' << t(:forum_file_list) << '</b></span>'
    form_string <<   '<span style="display:table-cell;padding-left:2%">'
    form_string <<    '<hr class="forum_post_attachment_line"/>'
    form_string <<   '</span>'
    form_string << '</div>'

    #Link para lightbox
    form_string << '<a href="#" class="forum_button_attachment" onclick="showUploadForm(\''<< post[:discussion_id].to_s << '\',\'' << post[:id].to_s << '\');">'<< t(:forum_attach_file) << '&nbsp;' << (image_tag "more.png", :alt => t(:forum_attach_file)) << '</a>' if editable && can_interact

    #Lista de arquivos
    unless post.discussion_post_files.count == 0
      form_string <<      '<ul class="forum_post_attachment">'
      post.discussion_post_files.each do |file|
        form_string <<   '<li>'
        form_string <<   '<a href="#">'<<(link_to file.attachment_file_name, :controller => "discussions", :action => "download_post_file", :idFile => file.id, :id => @discussion.id)<<'</a>&nbsp;&nbsp;'
        form_string <<   (link_to (image_tag "discussion_file_remove.png", :alt => t(:forum_remove_file)), {:controller => "discussions", :action => "remove_attached_file", :idFile => file.id, :id => @discussion.id}, :confirm=>t(:forum_remove_file_confirm), :title => t(:forum_remove_file)) if editable && can_interact
        form_string <<   '</li>'
      end
      form_string <<      '</ul>'
    else
      form_string << "<p class=\"forum_post_attachment_empty\">#{t(:forum_empty_file_list)}</p>"
    end
    

    return form_string
  end

  #Form de upload de arquivos dentro de um post
  def show_buttons(editable = false, can_interact = false, post=nil)
    post_string = ''

    post_string << '<div class="forum_post_buttons">'
    if editable && can_interact
      post_string <<      '   <a href="javascript:removePost(' << post[:id].to_s << ')" class="forum_button forum_button_remove">' << t('forum_show_remove') << '</a>&nbsp;&nbsp;
                              <a href="javascript:setDiscussionPostId(' << post[:id].to_s << ')" class="forum_button updateDialogLink ">' << t('forum_show_edit') << '</a>&nbsp;&nbsp;
                              <a href="javascript:setParentPostId(' << post[:id].to_s << ')" class="postDialogLink forum_button">' << t('forum_show_answer') << '</a>'
    elsif editable && !can_interact
      post_string <<      '    <a class="forum_post_link_disabled forum_post_link_remove_disabled">' << t('forum_show_remove') << '</a>&nbsp;&nbsp;
                               <a class="forum_post_link_disabled">' << t('forum_show_edit') << '</a>&nbsp;&nbsp;
                               <a class="forum_post_link_disabled">' << t('forum_show_answer') << '</a>'
    elsif !editable && can_interact
      post_string <<      '   <a href="javascript:setParentPostId(' << post[:id].to_s << ')" class="postDialogLink forum_button">' << t('forum_show_answer') << '</a>'
    elsif !editable && !can_interact
      post_string <<      '  <a class="forum_post_link_disabled">' << t('forum_show_answer') << '</a>'
    end
    post_string <<      '</div>'

    return post_string
  end
  
  #Verifica se a messagem foi postada hoje ou não!
  def posted_today?(message_datetime)
    message_datetime === Date.today
  end

end
