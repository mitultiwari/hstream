$(function() {
  $(document).ready(getShortlistFromHash);
  $(document).ready(setupColumns);
  $(document).ready(postProcess);
  $('.item .moreComments').live('click', toggleContext);
  $('.follow').live('click', toggleFollow);
  setupNewColumnHandlers('.story a');
  setupNewColumnHandlers('a.story');
  setupNewColumnHandlers('a.author');
});

function setupNewColumnHandlers(selector) {
  $(selector).live('mouseover', addRarr);
  $(selector).live('mouseout', rmRarr);
  $(selector).live('click', newColumn);
}

var maxColumns = 0;
var columnWidth = 0;
function setupColumns() {
setTimeout(function() { // wait for initial slideDown; it messes with pagetop.width
  columnWidth = $('#stream').outerWidth(false);
  var intercolumnGutter = 20; // sync with .column .view margin-left
  var availableSpace = $('#pagetop').outerWidth();

  maxColumns = intDiv(availableSpace, columnWidth);
  if (maxColumns < 1) maxColumns = 1;

  columnWidth = (availableSpace - (maxColumns-1)*intercolumnGutter) / maxColumns;
  $('.column').width(columnWidth);
}, 100);
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
    var column = $('#'+newColumnId);
    $('#'+newColumnId).remove();
    $('#stream').after(column);
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
  if (columnWidth > 0)
    $('.column').width(columnWidth);
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
