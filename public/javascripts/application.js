$(function() {
  $(document).ready(getShortlistFromHash);
  $(document).ready(setupColumns);
  $(document).ready(postProcess);
  $('.item .moreComments').live('click', toggleContext);
  $('.follow').live('click', toggleFollow);
  $('[href*="news.ycombinator.com"]').live('mouseover', addRarr);
  $('[href*="news.ycombinator.com"]').live('mouseout', rmRarr);
  $('[href*="news.ycombinator.com"]').live('click', newColumn);
});

var maxColumns = 0;
var columnWidth = 0;
function setupColumns() {
//  alert($('#pagetop').innerWidth()+' '+$('#pagetop').width()+' '+$('#pagetop').outerWidth());
  columnWidth = $('#stream').outerWidth(false);
  var intercolumnGutter = 20; // sync with .content .view margin-left
  var availableSpace = $('#pagetop').outerWidth()-15;
  alert(availableSpace+' '+$('#pagetop').width());

  maxColumns = intDiv(availableSpace, columnWidth);
  if (maxColumns < 1) maxColumns = 1;

  columnWidth = (availableSpace - (maxColumns-1)*intercolumnGutter) / maxColumns;
  alert(columnWidth+' '+maxColumns);
  $('.content').width(columnWidth);
}

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



function addRarr() {
  $(this).html($(this).html()+' &rarr;');
}
function rmRarr() {
  var old = $(this).html();
  if(old.charAt(old.length-2) == ' ')
    $(this).html(old.substring(0, old.length-2));
}

function newColumn() {
  ajax({url: convertUrl($(this))});
  return false;
}

function convertUrl(elem) {
  return elem.attr('href').
      replace('http://news.ycombinator.com', '').
      replace(/^\/item\?id=/, '/story/').
      replace('?id=', '/') + '.js';
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
  $('.content').width(columnWidth);
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

function intDiv(a, b) {
  return (a - a%b) / b;
}
