$(function() {
  $(document).ready(loadNewItems);
  $('.item .contextbutton').live('click', toggleContext);
  shortlistHandlers();
});

var mostRecentItem = 0;
function loadNewItems() {
  ajax({
    url: '/.js',
    method: 'get',
    data: {
      mostRecentItem: mostRecentItem,
      shortlist: keys(shortlist).join(),
    },
  });
  setTimeout(loadNewItems, 5000);
  return false;
}



function toggleContext() {
  $(this).parent().children('.context').slideToggle();
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

  var hnid = $(this).attr('hnid');
  if (shortlist[hnid]) return true;
  shortlist[hnid] = true;

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



function keys(obj) {
  var ans = [];
  for (var field in obj) {
    ans.push(field);
  }
  return ans;
}
