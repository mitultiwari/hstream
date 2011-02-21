$(function() {
  $(document).ready(loadNewItems);
  shortlistHandlers();
});

var mostRecentItem = 0;
function loadNewItems() {
  ajax({
    url: '/.js',
    method: 'get',
    data: {
      mostRecentItem: mostRecentItem,
    },
  });
  setTimeout(loadNewItems, 5000);

  return false;
}



function shortlistHandlers() {
  $('#stream .item').live('click', copyIntoShortlist);
  $('.shortlistClose').live('click', deleteFromShortlist);
}

var shortlist = new Object;
function copyIntoShortlist() {
  if ($('#shortlist .item').length == 0) {
    $('.content').animate({width: '49%'});
  }

  shortlist[$(this).attr('hnid')] = true;

  var itemCopy = $(this).clone();
  itemCopy.hide();
  itemCopy.prepend("<div class='shortlistClose'>x</div>");
  $('#shortlist').prepend(itemCopy);
  itemCopy.slideDown();
  return true;
}

function deleteFromShortlist() {
  var item = $(this).parent();
  delete shortlist[item.attr('hnid')];
  item.slideUp();
  item.remove();

  if ($('#shortlist .item').length == 0) {
    $('.content').animate({width: '99%'});
  }

  return false;
}



function postProcess() {
  $('.item').remove(':nth-child(30)')
  $('a').attr('target', 'blank');
}

function ajax(args) {
  $.ajax($.extend(args, {
    complete: postProcess,
  }));
}

function meths(obj) {
  var ans = [];
  for (var field in obj) {
    ans.push(field);
  }
  return ans;
}
