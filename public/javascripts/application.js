$(function() {
  $(document).ready(perpetuallyRefreshPage);
  $('.item .contextbutton').live('click', toggleContext);
  shortlistHandlers();
});

var mostRecentItem = 0;
var refreshShortlist = '';
function perpetuallyRefreshPage() {
  refreshPage();
  setTimeout(perpetuallyRefreshPage, 30000);
  return false;
}

function refreshPage() {
  ajax({
    url: '/.js',
    method: 'get',
    data: {
      mostRecentItem: mostRecentItem,
      shortlist: shortlist.join(),
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
  $('#shortlist .shortlistClose').live('click', deleteFromShortlist);
}

var shortlist = [];
function copyIntoShortlist() {
  var hnid = $(this).attr('hnid');
  if ($.inArray(hnid, shortlist) >= 0) return true;
  shortlist.splice(0, 0, hnid);

  var itemCopy = $(this).clone();
  itemCopy.hide();
  $('#shortlist').prepend(itemCopy);
  itemCopy.slideDown();

  $(this).slideUp();
  $(this).hide();

  return true;
}

function deleteFromShortlist() {
  var item = $(this).closest('.item');
  var hnid = item.attr('hnid');

  var orig = $('#stream [hnid="'+hnid+'"]');
  if (orig) orig.slideDown();

  var shortlistIdx = $.inArray(item.attr('hnid'));
  shortlist.splice(shortlistIdx, 1);
  item.slideUp();
  item.remove();
  return false;
}

function hnid(url) {
  return url.replace('http://news.ycombinator.com/item?id=', '');
}



function postProcess() {
  $('.item').remove(':nth-child(30)')
  $('a').attr('target', '_blank');
}

function ajax(args) {
  $.ajax($.extend(args, {
    complete: postProcess,
  }));
}
