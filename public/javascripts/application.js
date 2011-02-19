function setupPage() {
  loadNewItems();
  setTimeout(setupPage, 5000); // keep sync'd with crawler RECENCY_THRESHOLD
}

var mostRecentItem = 0;
function loadNewItems() {
  new Ajax.Request('/', {
      parameters: {
        mostRecentItem: mostRecentItem,
      },
    });
  return false;
}
