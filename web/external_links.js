// Keep keyboard interaction with embedded native links in the browser.
// Register before Flutter's global keyboard listeners.
function preserveNativeLinkKeys(event) {
  const isWebsiteLink = event.composedPath().some(
    (node) => node instanceof HTMLAnchorElement &&
      node.classList.contains('yro-external-link'),
  );
  if (isWebsiteLink) event.stopImmediatePropagation();
}

window.addEventListener('keydown', preserveNativeLinkKeys, true);
window.addEventListener('keyup', preserveNativeLinkKeys, true);
