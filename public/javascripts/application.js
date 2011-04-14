$(function() {
  $(document).ready(getShortlistFromHash);
  $(document).ready(setupColumns);
  $(document).ready(postProcess);
  $('.item .moreComments').live('click', toggleContext);
  $('.follow').live('click', toggleFollow);
  setupNewColumnHandlers('.story a');
  setupNewColumnHandlers('a.story');
  setupNewColumnHandlers('a.author');
  $('#more-items').click(showNewItems);
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

function ajax(args) {
  $.ajax($.extend(args, {
    complete: postProcess,
  }));
}

var title = $('title').html();
function postProcess() {
  $('#more-items').html(moreItemMessage());
  $('title').html(titlePrefix()+' '+title);
  $('a').attr('target', '_blank');
  if (columnWidth > 0)
    $('.column').width(columnWidth);
  schedulePageRefresh();
}

function moreItemMessage() {
  var numNewItems = Math.min($('#stream .holding').children('.item').length, 30);
  if (numNewItems == 0) return '';
  if (numNewItems == 1) return '1 new post';
  return numNewItems+' new posts';
}

function titlePrefix() {
  var numNewItems = Math.min($('#stream .holding').children('.item').length, 30);
  if (numNewItems == 0) return '';
  return '('+numNewItems+')';
}

function showNewItems() {
  $('title').html(title);
  $('#more-items').html('');
  $('#stream').prepend($('#stream .holding').children());
  $('.item').slideDown();
  $('#stream .item:gt(30)').remove();
}

function toggleContext() {
  metric('context?'+$(this).parents('.item').attr('hnid'));
  $(this).siblings('.context').slideToggle();
  return false;
}



var maxColumns = 0;
var columnWidth = 0;
function setupColumns() {
setTimeout(function() { // wait for initial slideDown; it messes with pagetop.width
  columnWidth = $('#stream').outerWidth(false);
  var intercolumnGutter = 20; // sync with .column .view margin-left
  var availableSpace = $('#pagetop').outerWidth()-1;

  maxColumns = intDiv(availableSpace, columnWidth);
  if (maxColumns < 1) maxColumns = 1;

  columnWidth = (availableSpace - (maxColumns-1)*intercolumnGutter) / maxColumns;
  $('.column').width(columnWidth);
}, 100);
}

function setupNewColumnHandlers(selector) {
  $(selector).live('mouseover', addRarr);
  $(selector).live('mouseout', rmRarr);
  $(selector).live('click', newColumn);
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
  $(this).trigger('mouseout');
  var newColumnId = convertId($(this));
  if ($('#'+newColumnId).length)
    slideColumnLeft(newColumnId);
  else
    insertColumnLeft(newColumnId);
  return false;
}

function insertColumnLeft(newColumnId) {
  if ($('.column').length == maxColumns) {
    $('.column:last .item').slideUp();
    setTimeout(function() {
      $('.column:last').remove();
    }, 200);
  }
  ajax({url: convertUrl(newColumnId)});
}

function slideColumnLeft(newColumnId) {
  $('#'+newColumnId+' .item').slideUp();
  setTimeout(function() {
    var column = $('#'+newColumnId).parent('.column');
    column.remove();
    $('#stream_column').after(column);
    setTimeout(function() {
      $('#'+newColumnId+' .item').slideDown();
    }, 200);
  }, 200);
}

function convertId(elem) {
  return elem.attr('href').
      replace('http://news.ycombinator.com/', '').
      replace(/^item\?id=/, 'story_').
      replace('?id=', '_');
}

function convertUrl(id) {
  return '/'+id.replace('_', '/')+'.js';
}



var shortlist = [];
function getShortlistFromHash() {
  shortlist = locationHashArray();
}

function toggleFollow() {
  var followee = $(this).attr('followee');
  metric('follow?'+followee);
  if ($.inArray(followee, shortlist) != -1) {
    $('.follow[followee='+followee+']').html('+');
    deleteFromArray(followee, shortlist);
    removeFromHash(followee);
  }
  else {
    $('.follow[followee='+followee+']').html('-');
    shortlist.push(followee);
    addToHash(followee);
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



function hnid(url) {
  return url.replace('http://news.ycombinator.com/item?id=', '');
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
