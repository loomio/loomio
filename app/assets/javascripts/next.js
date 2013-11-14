//= require jquery
//= require jquery_ujs
//= require holder.min
//= require twitter/bootstrap

stickyMotion = function(){
  if ($('#js-mini-motion').length > 0){
    mini_motion = $('#js-mini-motion');
    var elTop = mini_motion.offset().top - parseFloat(mini_motion.css('marginTop').replace(/auto/, 100));
    mini_motion.hide()
    $(window).scroll(function (event) {
      // what the y position of the scroll is
      var y = $(this).scrollTop();

      // whether that's below the form
      if (y >= elTop) {
        // if so, ad the fixed class
        mini_motion.addClass('fixed');
        mini_motion.show()
      } else {
        // otherwise remove it
        mini_motion.removeClass('fixed');
        mini_motion.hide()
      }
    });
  }
}

togglingCommentBox = function(){
  mini = $('#collapsed-comment-box')
  maxi = $('#expanded-comment-box')
  maxi.hide();
  expandCommentBox = function(){
  	maxi.show()
  	$('#expanded-input').focus()
  	mini.hide()
  }
  collapseCommentBox = function(){
  	mini.show()
  	maxi.hide()
  }
  mini.on('focus', 'input', expandCommentBox)
  maxi.on('blur', 'textarea', collapseCommentBox)

  $('.card-page').on('click', '.reply', function(){
    expandCommentBox();
    return false;
  })
}

expandSearchBox = function(){
  $('.search input').show()
  $('.nav-buttons').hide()
}

collapseSearchBox = function(){
  $('.search input').hide()
  $('.nav-buttons').show()
}

togglingSearchBox = function(){
  collapseSearchBox();
  $('.navbar').on('click', '.icon-ios7-search-strong', function(){
    expandSearchBox();
    return false;
  })
  $('.navbar').on('blur', 'input', function(){
    collapseSearchBox();
    return false;
  })
  // expandSearchBox();
}

hideDecisionForms = function(){
  $('.new-position .agree').hide()
  $('.new-position .abstain').hide()
  $('.new-position .disagree').hide()
  $('.new-position .block').hide()
}

showDecisionForm = function(el){
  hideDecisionForms();
  $('.new-position .' + el).show()
}

decisionButtons = function(){
  hideDecisionForms();
  btns = $('.decision-buttons')
  if (btns.length > 0){
    btns.on('click', 'i', function(){
      showDecisionForm($(this).parent().attr('class'))
    })

  }
}

$(document).ready(function () {
  if ($('.discussion').length > 0){
    stickyMotion()
    togglingCommentBox()
    decisionButtons()
  }
  togglingSearchBox()

});
