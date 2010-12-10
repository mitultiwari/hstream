function setupPage() {
  loadNewItems();
  setTimeout(setupPage, 5000); // keep sync'd with crawler RECENCY_THRESHOLD
}

function loadNewItems() {
  //alert($('.item').length);
}
