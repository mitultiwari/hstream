$(function() {
  $(document).ready(loadNewItems);
  $('.item').live('click', copyIntoShortlist);
});

var mostRecentItem = 0;
function loadNewItems() {
  ajax({
    url: '/.js',
    method: 'get',
    data: {
      mostRecentItem: mostRecentItem,
    },
  });
  setTimeout(loadNewItems, 5000);

  return false;
}

var shortlist = new Object;
function copyIntoShortlist() {
  shortlist[$(this).attr('hnid')] = true;
  return true; // clicks get processed further
}

function postProcess() {
  $('a').attr('target', 'blank');
}

function ajax(args) {
  $.ajax($.extend(args, {
    complete: postProcess,
  }));
}

function meths(obj) {
  var ans = [];
  for (var field in obj) {
    ans.push(field);
  }
  return ans;
}
