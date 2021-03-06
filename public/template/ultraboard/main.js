$(function(){
	var $top = ( $(window).height() - $('img#loading').height() ) / 2;
	var $left = ( $(window).width() - $('img#loading').width() ) / 2;
	$('img#loading')
		.css({'top': $top, 'left': $left})
		.show();
	$('<a style="float:left; margin:-2px 0 0 -2px;" href="http://www.tumblr.com/theme/19513"><img src="http://static.tumblr.com/s5hml8q/RJildsjv4/logo.png"/></a>')
		.appendTo('div#bottom');
	$('div#container')
		.hover(
			function(){$('div#info').fadeOut();}, 
			function(){$('div#info').fadeIn();}
		);
	$('span#follow')
		.toggle(
			function(){
				$('#following').animate({'height':'50%'});
			}, 
			function(){
				$('#following').animate({'height':'0px'});
			}
		);
	$('span#group')
		.toggle(
			function(){
				$('#following').animate({'height':'106px'});
			}, 
			function(){
				$('#following').animate({'height':'0px'});
			}
		);
	$('span#liked')
		.toggle(
			function(){
				$('#likes_container').animate({'height':'50%'});
			}, 
			function(){
				$('#likes_container').animate({'height':'0px'});
			}
		);
	$('#following img, li.like_post')
		.css({'opacity':0.5})
		.hover(
			function(){$(this).animate({'opacity':1});}, 
			function(){$(this).animate({'opacity':0.5});}
		);
});

$(window).load(function() {
	$('#loading').fadeOut();
	$('.content').fadeIn(1000);
});