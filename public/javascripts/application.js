var pollInterval = 29000;
$(function() {
  $(document).ready(getShortlistFromHash);
  $('.follow').live('click', toggleFollow);

  $(document).ready(setupColumns);
  $('.story a').live('click', newColumn);
  $('a.story').live('click', newColumn);
  $('a.author').live('click', newColumn);
  $('a.comment').live('click', newColumn);
  $('.new_column_link').click(newColumn);

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
  $('#spinner').hide();
  if (shortlist.length > 0) {
    $('#follow-call').hide();
    if (!getCookie('email')) {
      $('.login-call').show();
    }
  }

  moreItemMessage();
  $('.column').children().children('.item').slideDown();
  $('title').html(titlePrefix()+title);
  $('a').attr('target', '_blank');
  if (columnWidth > 0)
    $('.column').width(columnWidth);
  for (var i = 0; i < shortlist.length; ++i) {
    $('.item[author='+shortlist[i]+']').addClass('shortlist');
    $('.item[story_hnid='+shortlist[i]+']').addClass('shortlist');
    $('.follow[followee='+shortlist[i]+']').html('following');
    $('.follow[followee='+shortlist[i]+']').addClass('following');
    $('.follow[followee='+shortlist[i]+']').hover(
      function() {
        $(this).html('unfollow');
      },
      function() {
        $(this).html('following');
      });
    if (!getCookie('email'))
      $('.follow[followee='+shortlist[i]+']').parents('.column').find('.login-call').slideDown();
  }
}

var maxColumnCapacity = 30;
function moreItemMessage() {
  var numNewItems = Math.min($('#stream .holding').children('.item').length, maxColumnCapacity);
  if (numNewItems == 0) return;
  if (numNewItems == 1) $('#more-items').html('1 new post');
  else $('#more-items').html(numNewItems+' new posts');
  $('#more-items').slideDown();
}

function titlePrefix() {
  var numNewItems = Math.min($('#stream .holding').children('.item').length, maxColumnCapacity);
  if (numNewItems == 0) return '';
  if (numNewItems == maxColumnCapacity) return '';
  return '('+numNewItems+') ';
}

function showNewItems() {
  $('title').html(title);
  $('#more-items').hide();
  $('#more-items').html('');

  var cols = columnIds();
  for (var i = 0; i < cols.length; ++i) {
    var selector = '#'+cols[i];
    $(jqEsc(selector)).prepend($(jqEsc(selector)+' .holding').children());
  }

  $('.item').slideDown();
  $('#stream .item:gt('+maxColumnCapacity+')').remove();

  $.ajax({url: '/more'});
}

function toggleContext() {
  $.ajax({url: '/context?'+$(this).parents('.item').attr('hnid')});

  var context = $(this).siblings('.context');
  context.slideToggle();

  var old = $(this).html();
  if (old.charAt(old.length-1) == String.fromCharCode(8595)) { // &darr;
    $(this).html(old.substring(0, old.length-1)+"&uarr;");
  } else {
    $(this).html(old.substring(0, old.length-1)+"&darr;");
  }
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
  $('#spinner').width(columnWidth-10); // HACK: not sure why this needs to be narrower.
}, 300);
}

function columnIds() {
  return $.map($('.column').children('div[id]'), function(elem) { return elem.id; });
}

function newColumn() {
  if (maxColumns < 2) return true;
  $(this).trigger('mouseout');
  var newColumnId = $(this).attr('followee') || convertId($(this));
  if (newColumnId.match(/^http:/) || newColumnId[0] == '/') {
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
    $('.column:last').slideUp('slow', function() {
      $('.column:last').remove();
      $('#stream_column').after($('#spinner'));
      if ($('.column').length < maxColumns) { // just in case response returned really fast
        $('#spinner').show();
      }
    });
  }

  ajax({
    url: convertUrl(newColumnId),
    data: {
      until: mostRecentItem,
    }
  });
}

function slideColumnLeft(newColumnId) {
  $('#'+jqEsc(newColumnId)).slideUp('fast', function() {
    var column = $('#'+jqEsc(newColumnId)).parent('.column');
    column.remove();
    $('#stream_column').after(column);
    $('#'+jqEsc(newColumnId)).slideDown();
  });
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
  $('#follow-call').slideUp();
  if ($.inArray(followee, shortlist) != -1) {
    $.ajax({url: '/follow/'+followee,
      type: 'delete'});
    $('.follow[followee='+followee+']').html('follow');
    $('.follow[followee='+followee+']').removeClass('following');
    $('.follow[followee='+followee+']').unbind('mouseenter');
    $('.follow[followee='+followee+']').unbind('mouseleave');
    $('.item[author='+followee+']').removeClass('shortlist');
    $('.item[story_hnid='+followee+']').removeClass('shortlist');
    deleteFromArray(followee, shortlist);
    removeFromHash(followee);
    postProcess(); // refollow items with other reasons to be followed
    $(this).parents('.column').find('.login-call').slideUp();
  }
  else {
    $.ajax({url: '/follow',
      data: {id: followee},
      type: 'post'});
    $('.follow[followee='+followee+']').html('following');
    $('.follow[followee='+followee+']').addClass('following');
    $('.follow[followee='+followee+']').hover(
      function() {
        $(this).html('unfollow');
      },
      function() {
        $(this).html('following');
      });
    $('.item[author='+followee+']').addClass('shortlist');
    $('.item[story_hnid='+followee+']').addClass('shortlist');
    shortlist.push(followee);
    addToHash(followee);
    if (!getCookie('email'))
      $(this).parents('.column').find('.login-call').slideDown();
  }
  return true;
}

function userLoggedIn() {
  $('.login-call').slideUp();
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
