$(document).ready(function() {
$(".photoShell img").lazyload({
placeholder: "http://william.rainbird.me/boston-polaroid/white.gif",
threshold: 200
});


window.viewport =
{
height: function() {
return $(window).height();
},

width: function() {
return $(window).width();
},

scrollTop: function() {
return $(window).scrollTop();
},

scrollLeft: function() {
return $(window).scrollLeft();
}

};

$(".photoShell img").hide();
$(".photoShell .caption").hide();
    
$(".photoShell .photoShellInner img").load(function() {

var maxWidth = viewport.width() - 40; // Max width for the image
var maxHeight = viewport.height() - 50;    // Max height for the image
var ratio = 0;  // Used for aspect ratio
var width = $(this).width();    // Current image width
var height = $(this).height();  // Current image height


        // Check if the current width is larger than the max
        if(width > maxWidth){
            ratio = maxWidth / width;   // get ratio for scaling image
            $(this).css("width", maxWidth); // Set new width
            $(this).css("height", height * ratio);  // Scale height based on ratio
            height = height * ratio;    // Reset height to match scaled image
            width = width * ratio;    // Reset width to match scaled image
          
        }
 
        // Check if current height is larger than max
        if(height > maxHeight){
            ratio = maxHeight / height; // get ratio for scaling image
            $(this).css("height", maxHeight);   // Set new height
            $(this).css("width", width * ratio);    // Scale width based on ratio
            width = width * ratio;    // Reset width to match scaled image
        }

        
        $(this).parents('div.photoShell').css("width", $(this).width() + 22);
        $(this).parents('div.photoShell .photoShellInner').addClass('loaded');
        $(this).next(".caption").show();
        
		var $scrollNum =  $(this).parents('div.photoShell').offset().top;
		$.scrollTo($scrollNum, {duration: 700, axis:"y"});
        
        //window.location.href = "#" + postCounter;
        
        	var divWidth = $(this).parents('div.photoShell').width();
        	$(this).fadeIn("slow");
        
        	
        	if(divWidth < 400) {
        		$(this).parents('div.photoShell').addClass('small');
				$(this).next().children('.caption p').css("width", divWidth - 22);
        	} else {
        		$(this).parents('div.photoShell').removeClass('small');
        	
        	}

}).each(function() {
    // trigger the load event in case the image has been cached by the browser
    if(this.complete) $(this).trigger('load');
});

    

    
       function browserResize() {
    $('.photoShell img').each(function() {
    if(this.complete) $(this).trigger('load');

  $('.photoShell img').load(function() { 
		var maxWidth = viewport.width() - 40; // Max width for the image
		if(maxWidth > 1280){
			maxWidth = 1280;
		}
		
		var maxHeight = viewport.height() - 50;    // Max height for the image
		var ratio = 0;  // Used for aspect ratio
		
				
		$(this).css('width','auto');
		$(this).css('height','auto');
		
		var width = $(this).width();    // Current image width
		var height = $(this).height();  // Current image height
 
        // Check if the current width is larger than the max
        if(width > maxWidth){
            ratio = maxWidth / width;   // get ratio for scaling image
            $(this).css("width", maxWidth); // Set new width
            $(this).css("height", height * ratio);  // Scale height based on ratio
            height = height * ratio;    // Reset height to match scaled image
            width = width * ratio;    // Reset width to match scaled image
          
        }
 
        // Check if current height is larger than max
        else if(height > maxHeight){
            ratio = maxHeight / height; // get ratio for scaling image
            $(this).css("height", maxHeight);   // Set new height
            $(this).css("width", width * ratio);    // Scale width based on ratio
            width = width * ratio;    // Reset width to match scaled image
        }
        


	$(this).parents('div.photoShell').css("width", $(this).width() + 22);
	
	var divWidth = $(this).parents('div.photoShell').width();
	
	if(divWidth < 400) {
		$(this).parents('div.photoShell').addClass('small');
		$(this).next().children('.caption p').css("width", divWidth - 22);
	} else {
		$(this).parents('div.photoShell').removeClass('small');
	
	}
		
    });
    
    
    });
    
       };

	
});

    
