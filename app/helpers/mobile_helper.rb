# -*- coding: utf-8 -*-
module MobileHelper
  MOBILE_USER_AGENTS = 'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                       'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                       'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                       'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                       'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
                       'mobile'

  def set_mobile_format
    @has_mobile_view = true
    if params[:mobile].to_i == 1
      session[:mobile_view] = true 
    elsif params[:mobile].to_s == "0"
      session[:mobile_view] = false
    end
    if session[:mobile_view].nil? && is_mobile_device?
      session[:mobile_view] = true 
    elsif session[:mobile_view].nil?
      session[:mobile_view] = false
    end
    request.format = :mobile if session[:mobile_view]
  end

  def in_mobile_view?
    request.format.to_sym == :mobile
  end

  def is_mobile_device?
    request.user_agent.to_s.downcase =~ Regexp.new(MOBILE_USER_AGENTS)
  end

  def mobile_view?
    session[:mobile_view]
  end

end
