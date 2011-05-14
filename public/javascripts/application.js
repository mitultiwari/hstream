var pollInterval = 29000;
$(function() {
  $(document).ready(getShortlistFromHash);
  $('.follow').live('click', toggleFollow);

  $(document).ready(setupColumns);
  setupNewColumnHandlers('.story a');
  setupNewColumnHandlers('a.story');
  setupNewColumnHandlers('a.author');
  $('a.comment').live('click', newColumn);
  $('#active_users_link').click(newColumn);
  $('#active_stories_link').click(newColumn);

  $(document).ready(postProcess);
  setTimeout(refreshPage, pollInterval);
  $('#more-items').click(showNewItems);
  $('.item .moreComments').live('click', toggleContext);
});

function refreshPage() {
  ajax({
    url: location.pathname+'.js',
    method: 'get',
    data: {
      mostRecentItem: mostRecentItem,
      columns: columnIds().join(),
    },
  });
  setTimeout(refreshPage, pollInterval);
}

function ajax(args) {
  $.ajax($.extend(args, {
    complete: postProcess,
  }));
}

var title = $('title').html();
function postProcess() {
  $('#more-items').html(moreItemMessage());
  $('.column').children().children('.item').slideDown();
  $('title').html(titlePrefix()+title);
  $('a').attr('target', '_blank');
  if (columnWidth > 0)
    $('.column').width(columnWidth);
  for (var i = 0; i < shortlist.length; ++i) {
    $('.item[author='+shortlist[i]+']').addClass('shortlist');
    $('.item[story_hnid='+shortlist[i]+']').addClass('shortlist');
    $('.follow[followee='+shortlist[i]+']').html('-');
    if (!getCookie('email'))
      $('.follow[followee='+shortlist[i]+']').parents('.column').find('.message').slideDown();
  }
}

var maxColumnCapacity = 30;
function moreItemMessage() {
  var numNewItems = Math.min($('#stream .holding').children('.item').length, maxColumnCapacity);
  if (numNewItems == 0) return '';
  if (numNewItems == 1) return '1 new post';
  return numNewItems+' new posts';
}

function titlePrefix() {
  var numNewItems = Math.min($('#stream .holding').children('.item').length, maxColumnCapacity);
  if (numNewItems == 0) return '';
  if (numNewItems == maxColumnCapacity) return '';
  return '('+numNewItems+') ';
}

function showNewItems() {
  $('title').html(title);
  $('#more-items').html('');

  var cols = columnIds();
  for (var i = 0; i < cols.length; ++i) {
    var selector = '#'+cols[i];
    $(jqEsc(selector)).prepend($(jqEsc(selector)+' .holding').children());
  }

  $('.item').slideDown();
  $('#stream .item:gt('+maxColumnCapacity+')').remove();
}

function toggleContext() {
  $.ajax({url: '/context?'+$(this).parents('.item').attr('hnid')});
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
}, 300);
}

function setupNewColumnHandlers(selector) {
  $(selector).live('mouseover', addRarr);
  $(selector).live('mouseout', rmRarr);
  $(selector).live('click', newColumn);
}

function columnIds() {
  return $.map($('.column').children('div[id]'), function(elem) { return elem.id; });
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
  if (maxColumns < 2) return true;
  $(this).trigger('mouseout');
  var newColumnId = $(this).attr('followee') || convertId($(this));
  if (newColumnId.match(/^http:/)) {
    $(this).attr('href', newColumnId);
    return true;
  }

  if ($('#'+jqEsc(newColumnId)).length)
    slideColumnLeft(newColumnId);
  else
    insertColumnLeft(newColumnId);
  return false;
}

function insertColumnLeft(newColumnId) {
  if ($('.column').length >= maxColumns) {
    $('.column:last .item').slideUp();
    setTimeout(function() {
      $('.column:last').remove();
    }, 200);
  }

  ajax({
    url: convertUrl(newColumnId),
    data: {
      until: mostRecentItem,
    }
  });
}

function slideColumnLeft(newColumnId) {
  $('#'+jqEsc(newColumnId)+' .item').slideUp();
  setTimeout(function() {
    var column = $('#'+jqEsc(newColumnId)).parent('.column');
    column.remove();
    $('#stream_column').after(column);
    setTimeout(function() {
      $('#'+jqEsc(newColumnId)+' .item').slideDown();
    }, 200);
  }, 200);
}

function convertId(elem) {
  return elem.attr('href').
      replace('http://news.ycombinator.com/', '').
      replace(/^item\?id=/, 'story:').
      replace('?id=', ':');
}

function convertUrl(id) {
  return '/'+id.replace(':', '/')+'.js';
}



var shortlist = [];
function getShortlistFromHash() {
  shortlist = locationHashArray();
}

function toggleFollow() {
  var followee = $(this).attr('followee');
  if ($.inArray(followee, shortlist) != -1) {
    $.ajax({url: '/follow/'+followee,
      type: 'delete'});
    $('.follow[followee='+followee+']').html('+');
    $('.item[author='+followee+']').removeClass('shortlist');
    $('.item[story_hnid='+followee+']').removeClass('shortlist');
    deleteFromArray(followee, shortlist);
    removeFromHash(followee);
    postProcess(); // refollow items with other reasons to be followed
    $(this).parents('.column').find('.message').slideUp();
  }
  else {
    $.ajax({url: '/follow',
      data: {id: followee},
      type: 'post'});
    $('.follow[followee='+followee+']').html('-');
    $('.item[author='+followee+']').addClass('shortlist');
    $('.item[story_hnid='+followee+']').addClass('shortlist');
    shortlist.push(followee);
    addToHash(followee);
    if (!getCookie('email'))
      $(this).parents('.column').find('.message').slideDown();
  }
  return true;
}

function userLoggedIn() {
  $('.message').slideUp();
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
  if (location.hash == '' || location.hash == '#')
    return [];
  return location.hash.substring(1).split(',');
}

function intDiv(a, b) {
  return (a - a%b) / b;
}

function jqEsc(s) {
  return s.replace(':', '\\:');
}


function getCookie(name) {
  var nameEQ = name+"=";
  var cookies = document.cookie.split(';');
  for(var i=0; i < cookies.length; i++) {
    var c = $.trim(cookies[i]);
    if (c.indexOf(nameEQ) == 0)
      return c.substring(nameEQ.length, c.length);
  }
  return null;
}
