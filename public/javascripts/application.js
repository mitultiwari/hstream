$(function() {
  $(document).ready(perpetuallyRefreshPage);
  $('.item .contextbutton').live('click', toggleContext);
  shortlistHandlers();
});

var mostRecentItem = 0;
var refreshShortlist = '';
function perpetuallyRefreshPage() {
  refreshPage();
  setTimeout(perpetuallyRefreshPage, 5000);
  return false;
}

function refreshPage() {
  ajax({
    url: '/.js',
    method: 'get',
    data: {
      mostRecentItem: mostRecentItem,
      shortlist: keys(shortlist).join(),
      refreshShortlist: refreshShortlist,
    },
  });
  refreshShortlist = '';
}



function toggleContext() {
  $(this).siblings('.context').slideToggle();
  return false;
}

function shortlistHandlers() {
  $('#stream .item').live('click', copyIntoShortlist);
  $('.shortlistClose').live('click', deleteFromShortlist);
}

var shortlist = new Object;
function copyIntoShortlist() {
  if ($('#shortlist .item').length == 0) {
    $('.content').animate({width: '49.5%'});
  }

  var hnid = $(this).attr('hnid');
  if (shortlist[hnid]) return true;
  shortlist[hnid] = true;

  var itemCopy = $(this).clone();
  itemCopy.hide();
  itemCopy.find('.itembox').prepend("<div class='shortlistClose'>x</div>");
  itemCopy.find('a[href^="http://news.ycombinator.com/item"]').click(switchIntoShortlist);
  $('#shortlist').prepend(itemCopy);
  itemCopy.slideDown();

  return true;
}

function deleteFromShortlist() {
  var item = $(this).closest('.item');
  delete shortlist[item.attr('hnid')];
  item.slideUp();
  item.remove();

  if ($('#shortlist .item').length == 0) {
    $('.content').animate({width: '100%'});
  }
  return false;
}

function switchIntoShortlist() {
  var newhnid = $(this).closest('[hnid]').attr('hnid');
  shortlist[newhnid]=true;

  var item = $(this).closest('.item');
  var hnid = item.attr('hnid');
  delete shortlist[hnid];

  refreshShortlist = true;
  refreshPage();
  return false;
}



function postProcess() {
  $('.item').remove(':nth-child(30)')
  $('a').attr('target', 'blank');
  $('#shortlist').find('a[href^="http://news.ycombinator.com/item"]').click(switchIntoShortlist);
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
