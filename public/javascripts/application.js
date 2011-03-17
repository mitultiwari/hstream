$(function() {
  $(document).ready(getShortlistFromHash);
  $(document).ready(perpetuallyRefreshPage);
  $('.item .contextbutton').live('click', toggleContext);
  shortlistHandlers();
  $('.follow').live('click', toggleFollow);
});

var mostRecentItem = 0;
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
    },
  });
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
  shortlist.push(hnid);

  var itemCopy = $(this).clone();
  itemCopy.hide();
  $('#shortlist').prepend(itemCopy);
  itemCopy.slideDown();

  return true;
}

function deleteFromShortlist() {
  var item = $(this).closest('.item');
  var hnid = item.attr('hnid');

  deleteFromArray(hnid, shortlist);
  item.slideUp();
  setTimeout(function() {
    item.remove();
  }, 500);
  return false;
}

function hnid(url) {
  return url.replace('http://news.ycombinator.com/item?id=', '');
}



function toggleFollow() {
  var author = $(this).attr('author');
  if ($.inArray(author, shortlist) != -1) {
    $('.follow[author='+author+']').html('+');
    deleteFromArray(author, shortlist);
    removeFromHash(author);
  }
  else {
    $('.follow[author='+author+']').html('-');
    shortlist.push(author);
    addToHash(author);
  }
  return true;
}

function addToHash(word) {
  if (location.hash.match(new RegExp('\\b'+word+'\\b'))) return;
  location.hash += location.hash.match('#') ? ',' : '#';
  location.hash += word;
}

function removeFromHash(word) {
  if (location.hash == '') return;
  location.hash = '#' + deleteFromArray(word, hashArray()).join(',');
}

function getShortlistFromHash() {
  shortlist = hashArray();
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

function deleteFromArray(elem, array) {
  var idx = $.inArray(elem, array);
  array.splice(idx, 1);
  return array;
}

function hashArray() {
  return location.hash.substring(1).split(',');
}
