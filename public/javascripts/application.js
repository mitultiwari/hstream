$(function() {
  $(document).ready(getShortlistFromHash);
  $(document).ready(postProcess);
  $('.item .moreComments').live('click', toggleContext);
  $('.follow').live('click', toggleFollow);
});

var pollInterval = 29000;
function schedulePageRefresh() {
  setTimeout(refreshPage, pollInterval);
}

function refreshPage() {
  ajax({
    url: location.pathname+'.js',
    method: 'get',
    data: {
      mostRecentItem: mostRecentItem,
      shortlist: shortlist.join(),
    },
  });
}



function toggleContext() {
  metric('context?'+$(this).parents('.item').attr('hnid'));
  $(this).siblings('.context').slideToggle();
  return false;
}

function hnid(url) {
  return url.replace('http://news.ycombinator.com/item?id=', '');
}



function toggleFollow() {
  var author = $(this).attr('author');
  metric('follow?'+author);
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
  location.hash = '#' + deleteFromArray(word, locationHashArray()).join(',');
}

var shortlist = [];
function getShortlistFromHash() {
  shortlist = locationHashArray();
}



function postProcess() {
  $('#stream .item:gt(30)').remove();
  $('a').attr('target', '_blank');
  schedulePageRefresh();
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

function locationHashArray() {
  return location.hash.substring(1).split(',');
}

function metric(url) {
  $.ajax({
    url: '/'+url,
    method: 'get',
  });
}
