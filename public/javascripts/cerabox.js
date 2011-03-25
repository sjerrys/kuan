/**
 * @package		CeraBox
 * 
 * @author 		Sven
 * @since 		13-01-2011
 * @version 	1.2.11-r
 * 
 * This package requires MooTools 1.3.* + MooTools More Assets
 * 
 * @license The MIT License
 * 
 * Copyright (c) 2011-2012 Ceramedia, <http://ceramedia.nl/>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
var CeraBox=new Class({Implements:[Options],loaderTimer:null,timeOuter:null,vars:{items:new Array(),cerabox:null,windowOpen:false,busy:false,currentIndex:[0,0]},options:{group:true,errorLoadingMessage:"The requested content cannot be loaded. Please try again later.",events:{onClose:function(){},onOpen:function(){},onChange:function(){},_onClose:null,_onOpen:null,_onChange:null}},initialize:function(a){this.setOptions(a);this.initHTML();if(Browser.ie6){$("cerabox-loading").addClass("ceraboxbox-ie6")}window.addEvent("resize",this._resize.bind(this));$("cerabox-loading").addEvent("click",function(b){b.stop();this.close()}.bind(this));document.addEvent("keyup",function(b){if(b.key=="esc"){this.close()}if(b.target.get("tag")=="input"||b.target.get("tag")=="select"||b.target.get("tag")=="textarea"){return}if(b.key=="left"){this.vars.cerabox.getElement(".cerabox-left").fireEvent("click",b)}if(b.key=="right"){this.vars.cerabox.getElement(".cerabox-right").fireEvent("click",b)}}.bind(this))},addItems:function(a,c){var b=$$(a);if(b.length<1){throw"Empty container"}var d=this.vars.items.length;this.vars.items[d]=[];c=c?c:{};Array.each(b,function(f,e){if(c.group===false||(c.group!==true&&this.options.group===false)){this.vars.items[d]=[];this.vars.items[d][0]=f;e=[d,0];d=d+1}else{this.vars.items[d][e]=f;e=[d,e]}if(typeof c.ajax!="undefined"){f.addEvent("click",function(g){g.preventDefault();if(this.vars.busy){return}this.vars.busy=true;this._addCallbacks((typeof c.events!="undefined")?c.events:null);this.vars.cerabox.setStyle("cursor","auto").removeEvents("click");if(true===c.clickToClose){this.vars.cerabox.setStyle("cursor","pointer").addEvent("click",function(h){h.stop();this.close()}.bind(this))}this._showInit();this.showAjax(e,c)}.bind(this))}else{if(f.get("href").replace(/(\?.*)/,"").test(/\.jpg|jpeg|png|gif$/i)){f.addEvent("click",function(g){g.preventDefault();if(this.vars.busy){return}this.vars.busy=true;this._addCallbacks((typeof c.events!="undefined")?c.events:null);this.vars.cerabox.setStyle("cursor","auto").removeEvents("click");if(true===c.clickToClose){this.vars.cerabox.setStyle("cursor","pointer").addEvent("click",function(h){h.stop();this.close()}.bind(this))}this._showInit();this.showImage(e,c)}.bind(this))}else{if(f.get("href").test(/\.swf$/i)){f.addEvent("click",function(g){g.preventDefault();if(this.vars.busy){return}this.vars.busy=true;this._addCallbacks((typeof c.events!="undefined")?c.events:null);this.vars.cerabox.setStyle("cursor","auto").removeEvents("click");if(true===c.clickToClose){this.vars.cerabox.setStyle("cursor","pointer").addEvent("click",function(h){h.stop();this.close()}.bind(this))}this._showInit();this.showSwf(e,c)}.bind(this))}else{f.addEvent("click",function(g){g.preventDefault();if(this.vars.busy){return}this.vars.busy=true;this._addCallbacks((typeof c.events!="undefined")?c.events:null);this.vars.cerabox.setStyle("cursor","auto").removeEvents("click");if(true===c.clickToClose){this.vars.cerabox.setStyle("cursor","pointer").addEvent("click",function(h){h.stop();this.close()}.bind(this))}this._showInit();this.showIframe(e,c)}.bind(this))}}}}.bind(this))},showAjax:function(c,b){var e=this;var a=this.vars.items[c[0]];var d=a[c[1]];this.loaderTimer=this._displayLoader.delay(200,this);var f=new Request.HTML({url:d.get("href"),method:b.ajax.method?b.ajax.method:"post",data:b.ajax.data?b.ajax.data:"",onSuccess:function(h){if(false===e.vars.busy){return}clearInterval(e.loaderTimer);$("cerabox-loading").setStyle("display","none");if(false!==b.displayOverlay){e._displayOverlay()}var i=e.vars.cerabox.getElement("#cerabox-ajaxPreLoader").empty().adopt(h);e.vars.cerabox.setStyle("display","block");i.setStyle("width",b.width?b.width:i.getScrollSize().x+"px");i.setStyle("height",b.height?b.height:i.getScrollSize().y+"px");var g=e._getSizeElement(i,(true===b.fullSize?true:false));i=i.get("html");e.vars.cerabox.getElement("#cerabox-ajaxPreLoader").empty().setStyles({width:0,height:0});e.vars.cerabox.getElement(".cerabox-title span").setStyle("display","none").empty();if(e.vars.windowOpen==true){e._transformItem(g.width,g.height)}e.vars.cerabox.getElement(".cerabox-content").set("tween",{duration:300}).tween("opacity","0").get("tween").addEvent("complete",function(){this.removeEvents("complete");if(false===e.vars.busy){return}if(false!==b.displayTitle){e.vars.cerabox.getElement(".cerabox-title span").setStyle("display","block").set("text",(a.length>1?"Item "+(c[1]+1)+" / "+a.length+" ":"")+(d.get("title")?d.get("title"):""))}e.vars.cerabox.getElement(".cerabox-content").empty().set("opacity",0).set("html",i).set("tween",{duration:100}).tween("opacity","1");if(a.length>1){e._addNavButtons(c)}e._openWindow(g.width,g.height,b.animation?b.animation:"fade",c);if(true===b.fullSize){e._resize()}e.vars.busy=false})},onTimeout:function(){e._timedOut(c,b)},onFailure:function(){e._timedOut(c,b)},onException:function(){e._timedOut(c,b)}}).send()},showImage:function(c,b){var e=this;var a=this.vars.items[c[0]];var d=a[c[1]];this.loaderTimer=this._displayLoader.delay(200,this);var f=new Asset.image(d.get("href"),{onload:function(){if(false===e.vars.busy){return}clearInterval(e.loaderTimer);$("cerabox-loading").setStyle("display","none");if(false!==b.displayOverlay){e._displayOverlay()}this.set("width",b.width?b.width:this.get("width"));this.set("height",b.height?b.height:this.get("height"));var g=e._getSizeElement(this,(true===b.fullSize?true:false));e.vars.cerabox.getElement(".cerabox-title span").setStyle("display","none").empty();if(e.vars.windowOpen==true){e._transformItem(g.width,g.height)}e.vars.cerabox.getElement(".cerabox-content").set("tween",{duration:300}).tween("opacity","0").get("tween").addEvent("complete",function(){this.removeEvents("complete");if(false===e.vars.busy){return}if(false!==b.displayTitle){e.vars.cerabox.getElement(".cerabox-title span").setStyle("display","block").set("text",(a.length>1?"Item "+(c[1]+1)+" / "+a.length+" ":"")+(d.get("title")?d.get("title"):""))}e.vars.cerabox.getElement(".cerabox-content").empty().set("opacity",0).adopt(f).set("tween",{duration:100}).tween("opacity","1");if(a.length>1){e._addNavButtons(c)}e._openWindow(g.width,g.height,b.animation?b.animation:"fade",c);if(true===b.fullSize){e._resize()}e.vars.busy=false})},onerror:function(){e._timedOut(c,b)}})},showSwf:function(d,c){this.vars.busy=true;var f=this;var a=this.vars.items[d[0]];var e=a[d[1]];f.vars.cerabox.getElement(".cerabox-title span").setStyle("display","none").empty();var g={width:c.width?c.width:500,height:c.height?c.height:400};var b=new Swiff(e.get("href"),{width:g.width,height:g.height,params:{wMode:"opaque"}});if(false!==c.displayOverlay){f._displayOverlay()}if(f.vars.windowOpen==true){f._transformItem(g.width,g.height)}f.vars.cerabox.getElement(".cerabox-content").set("tween",{duration:300}).tween("opacity","0").get("tween").addEvent("complete",function(){this.removeEvents("complete");if(false===f.vars.busy){return}if(false!==c.displayTitle){f.vars.cerabox.getElement(".cerabox-title span").setStyle("display","block").set("text",(a.length>1?"Item "+(d[1]+1)+" / "+a.length+" ":"")+(e.get("title")?e.get("title"):""))}f.vars.cerabox.getElement(".cerabox-content").empty().set("opacity",0).adopt(b).set("tween",{duration:100}).tween("opacity","1");if(a.length>1){f._addNavButtons(d)}f._openWindow(g.width,g.height,c.animation?c.animation:"fade",d);if(true===c.fullSize){f._resize()}f.vars.busy=false})},showIframe:function(c,b){var f=this;var a=this.vars.items[c[0]];var e=a[c[1]];this.loaderTimer=this._displayLoader.delay(200,this);this.timeOuter=this._timedOut.delay(10000,this,[c,b]);var d=new IFrame({src:e.get("href"),events:{load:function(){f.vars.busy=true;clearInterval(f.timeOuter);clearInterval(f.loaderTimer);$("cerabox-loading").setStyle("display","none");if(false!==b.displayOverlay){f._displayOverlay()}this.setStyles({width:b.width?b.width:"1px",height:b.height?b.height:"1px",border:"0"});var g=f._getSizeElement(this,(true===b.fullSize?true:false));if(a.length>1){f._addNavButtons(c)}f.vars.cerabox.getElement(".cerabox-title span").setStyle("display","none").empty();if(f.vars.windowOpen==true){f._transformItem(g.width,g.height)}f._openWindow(g.width,g.height,b.animation?b.animation:"fade",c);if(true===b.fullSize){f._resize()}f.vars.cerabox.getElement(".cerabox-content").set("tween",{duration:100}).tween("opacity","1");f.vars.busy=false}}});d.set("border","0");d.set("frameborder","0");this.vars.cerabox.setStyle("display","block").getElement(".cerabox-content").empty().set("opacity",0).adopt(d)},close:function(){this.vars.busy=true;clearInterval(this.timeOuter);clearInterval(this.loaderTimer);$("cerabox-loading").setStyle("display","none");var a=this;a.vars.cerabox.set("tween",{duration:50}).tween("opacity","0").get("tween").addEvent("complete",function(){this.removeEvents("complete");this.element.setStyle("display","none");$("cerabox-background").set("tween",{duration:150,link:"chain"}).tween("opacity","0").tween("display","none");a.vars.cerabox.getElement(".cerabox-content").empty();a.vars.cerabox.getElement(".cerabox-left").removeEvents("click").setStyle("display","none");a.vars.cerabox.getElement(".cerabox-right").removeEvents("click").setStyle("display","none");var c=a.vars.items[a.vars.currentIndex[0]];var b=c[a.vars.currentIndex[1]];if(a.vars.windowOpen){if(null!==a.options.events._onClose){a.options.events._onClose.call(a,b,c)}else{a.options.events.onClose.call(a,b,c)}}a.vars.windowOpen=false;a.vars.busy=false})},initHTML:function(){var a=$(document.body);a.adopt([new Element("div",{id:"cerabox-loading"}).adopt(new Element("div")),new Element("div",{id:"cerabox-background",styles:{height:a.getScrollSize().y+"px"},events:{click:function(b){b.stop();this.close()}.bind(this)}}),this.vars.cerabox=new Element("div",{id:"cerabox"}).adopt([new Element("div",{"class":"cerabox-content"}),new Element("div",{"class":"cerabox-title"}).adopt(new Element("span")),new Element("a",{"class":"cerabox-close",events:{click:function(b){b.stop();this.close()}.bind(this)}}),new Element("a",{"class":"cerabox-left"}).adopt(new Element("span")),new Element("a",{"class":"cerabox-right"}).adopt(new Element("span")),new Element("div",{id:"cerabox-ajaxPreLoader",styles:{"float":"left",overflow:"hidden",display:"block"}})])])},_timedOut:function(c,b){this.vars.busy=true;clearInterval(this.loaderTimer);$("cerabox-loading").setStyle("display","none");this._displayOverlay();this.vars.cerabox.getElement(".cerabox-title span").setStyle("display","none").empty();var d=this;var a=this.vars.items[c[0]];this.vars.cerabox.getElement(".cerabox-content").set("tween",{duration:300}).tween("opacity","0").get("tween").addEvent("complete",function(){this.removeEvents("complete");if(false===d.vars.busy){return}d.vars.cerabox.getElement(".cerabox-content").empty().set("opacity",0).adopt(new Element("span",{text:d.options.errorLoadingMessage})).set("tween",{duration:100}).tween("opacity","1");if(a.length>1){d._addNavButtons(c)}d._openWindow(250,50,b.animation?b.animation:"fade",c);d.vars.busy=false});if(d.vars.windowOpen==true){d._transformItem(250,50)}},_addNavButtons:function(a){var b=this;this.vars.cerabox.getElement(".cerabox-left").removeEvents("click").setStyle("display","none");this.vars.cerabox.getElement(".cerabox-right").removeEvents("click").setStyle("display","none");if(this.vars.items[a[0]][(a[1]-1)]){this.vars.cerabox.getElement(".cerabox-left").setStyle("display","block").addEvent("click",function(c){c.stopPropagation();this.setStyle("display","none");b.vars.items[a[0]][(a[1]-1)].fireEvent("click",c)})}if(this.vars.items[a[0]][(a[1]+1)]){this.vars.cerabox.getElement(".cerabox-right").setStyle("display","block").addEvent("click",clickFnc=function(c){c.stopPropagation();this.setStyle("display","none");b.vars.items[a[0]][(a[1]+1)].fireEvent("click",c)})}},_transformItem:function(c,a){var b={display:"block",width:c,height:a,opacity:1};if(window.getSize().x>this.vars.cerabox.getSize().x+40&&window.getSize().x>c+40){this.vars.cerabox.setStyles({left:"50%",right:"auto"});b["margin-left"]=((-c/2)+$(document.body).getScroll().x)+"px"}else{this.vars.cerabox.setStyles({"margin-left":"0",left:"auto",right:"20px"})}if(window.getSize().y>this.vars.cerabox.getSize().y+40&&window.getSize().y>a+40){this.vars.cerabox.setStyles({top:"50%"});b["margin-top"]=((-a/2)+$(document.body).getScroll().y)+"px"}else{if(a+40>($(document.body).getScrollSize().y-$(document.body).getScroll().y)){this.vars.cerabox.setStyles({"margin-top":"0",top:($(document.body).getScrollSize().y-(a+60)>20?$(document.body).getScrollSize().y-(a+60):20)+"px"})}else{this.vars.cerabox.setStyles({"margin-top":"0",top:$(document.body).getScroll().y+20+"px"})}}return this.vars.cerabox.set("morph",{duration:150}).morph(b).get("morph")},_showInit:function(){clearInterval(this.timeOuter);clearInterval(this.loaderTimer);$("cerabox-loading").setStyle("display","none")},_openWindow:function(d,a,e,b){if(this.vars.cerabox.getElement(".cerabox-content iframe")){this.vars.cerabox.getElement(".cerabox-content iframe").setStyles({width:d,height:a})}this.vars.currentIndex=b;var c=this.vars.items[b[0]][b[1]];if(this.vars.windowOpen==true){if(null!==this.options.events._onChange){this.options.events._onChange.call(this,c,this.vars.items[b[0]])}else{this.options.events.onChange.call(this,c,this.vars.items[b[0]])}return}switch(e){case"ease":this.vars.cerabox.setStyles({display:"block",left:c.getPosition().x+"px",top:c.getPosition().y+"px",width:c.getSize().x+"px",height:c.getSize().y+"px",margin:0,opacity:0}).set("morph",{duration:200}).morph({left:((window.getSize().x/2))+"px",top:((window.getSize().y/2))+"px",width:d,height:a,"margin-left":((-d/2)+$(document.body).getScroll().x)+"px","margin-top":((-a/2)+$(document.body).getScroll().y)+"px",opacity:"1"});break;case"fade":default:this.vars.cerabox.setStyles({display:"block",left:"50%",top:"50%",width:d,height:a,opacity:0,"margin-left":((-d/2)+$(document.body).getScroll().x)+"px","margin-top":((-a/2)+$(document.body).getScroll().y)+"px"}).set("tween",{duration:150}).tween("opacity","1");break}if(null!==this.options.events._onOpen){this.options.events._onOpen.call(this,c,this.vars.items[b[0]])}else{this.options.events.onOpen.call(this,c,this.vars.items[b[0]])}c.blur();this.vars.windowOpen=true},_displayOverlay:function(){$("cerabox-background").setStyles({display:"block",opacity:".5",height:$(document.body).getScrollSize().y+"px",width:$(document.body).getScrollSize().x+"px"})},_displayLoader:function(){$("cerabox-loading").setStyle("display","block");this._loaderAnimation()},_loaderAnimation:function(a){if(!a){a=0}$("cerabox-loading").getElement("div").setStyle("top",(a*-40)+"px");a=(a+1)%12;if($("cerabox-loading").getStyle("display")!="none"){this._loaderAnimation.delay(60,this,a)}},_getSizeElement:function(b,f){var a=0,e=0;if(b.tagName=="IFRAME"){try{a=(b.get("width")?this._sizeStringToInt(b.get("width"),"x"):(b.getStyle("width").toInt()>1?this._sizeStringToInt(b.getStyle("width"),"x"):(b.contentWindow.document.getScrollWidth()?b.contentWindow.document.getScrollWidth():window.getSize().x*0.75)))}catch(d){a=window.getSize().x*0.75;this._log(d)}try{e=(b.get("height")?this._sizeStringToInt(b.get("height"),"y"):(b.getStyle("height").toInt()>1?this._sizeStringToInt(b.getStyle("height"),"y"):(b.contentWindow.document.getScrollHeight()?b.contentWindow.document.getScrollHeight():window.getSize().y*0.75)))}catch(d){e=window.getSize().y*0.75;this._log(d)}if(Browser.ie){e=e+20}if(false===f){if((window.getSize().y-100)<e){a=a+(Browser.Platform.mac?15:17)}return{width:(window.getSize().x-50)<a?(window.getSize().x-50):a,height:(window.getSize().y-100)<e?(window.getSize().y-100):e}}else{return{width:a,height:e}}}a=(b.get("width")?this._sizeStringToInt(b.get("width"),"x"):(b.getStyle("width")&&b.getStyle("width")!="auto"?this._sizeStringToInt(b.getStyle("width"),"x"):window.getSize().x-50));e=(b.get("height")?this._sizeStringToInt(b.get("height"),"y"):(b.getStyle("height")&&b.getStyle("height")!="auto"?this._sizeStringToInt(b.getStyle("height"),"y"):window.getSize().y-100));if(false===f){var c=Math.min(Math.min(window.getSize().x-50,a)/a,Math.min(window.getSize().y-100,e)/e);return{width:Math.round(c*a),height:Math.round(c*e)}}else{return{width:a,height:e}}},_sizeStringToInt:function(a,b){return(typeof a=="string"&&a.test("%")?window.getSize()[b]*(a.toInt()/100):a.toInt())},_resize:function(){if(this.vars.windowOpen==true){if(window.getSize().x>this.vars.cerabox.getSize().x+40){this.vars.cerabox.setStyles({"margin-left":(this.vars.cerabox.getSize().x>0?((-this.vars.cerabox.getSize().x/2)+$(document.body).getScroll().x):0)+"px",left:"50%",right:"auto"})}else{this.vars.cerabox.setStyles({"margin-left":"0",left:"auto",right:"20px"})}if(window.getSize().y>this.vars.cerabox.getSize().y+40){this.vars.cerabox.setStyles({"margin-top":(this.vars.cerabox.getSize().y>0?((-this.vars.cerabox.getSize().y/2)+$(document.body).getScroll().y):0)+"px",top:"50%",bottom:"auto"})}else{if(this.vars.cerabox.getSize().y+40>($(document.body).getScrollSize().y-$(document.body).getScroll().y)){this.vars.cerabox.setStyles({"margin-top":"0",top:($(document.body).getScrollSize().y-(this.vars.cerabox.getSize().y+60)>20?$(document.body).getScrollSize().y-(this.vars.cerabox.getSize().y+60):20)+"px"})}else{this.vars.cerabox.setStyles({"margin-top":"0",top:$(document.body).getScroll().y+20+"px"})}}$("cerabox-background").setStyles({height:$(document.body).getScrollSize().y+"px",width:$(document.body).getScrollSize().x+"px"})}},_addCallbacks:function(a){this.options.events._onClose=null;this.options.events._onOpen=null;this.options.events._onChange=null;if(null!==a){if(typeof a.onClose=="function"){this.options.events._onClose=a.onClose}if(typeof a.onOpen=="function"){this.options.events._onOpen=a.onOpen}if(typeof a.onChange=="function"){this.options.events._onChange=a.onChange}}},_log:function(a,c){try{console.log(a)}catch(b){if(c){alert(a)}}}});