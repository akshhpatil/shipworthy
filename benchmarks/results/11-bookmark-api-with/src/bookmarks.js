const { randomUUID } = require('crypto');

const bookmarks = new Map();

function list() {
  return Array.from(bookmarks.values());
}

function getById(id) {
  return bookmarks.get(id) || null;
}

function create({ title, url, tags }) {
  if (!title || !url) {
    throw new Error('title and url are required');
  }
  const bookmark = {
    id: randomUUID(),
    title,
    url,
    tags: tags || [],
    createdAt: new Date().toISOString(),
  };
  bookmarks.set(bookmark.id, bookmark);
  return bookmark;
}

function update(id, fields) {
  const existing = bookmarks.get(id);
  if (!existing) return null;
  const updated = { ...existing, ...fields, id, createdAt: existing.createdAt };
  bookmarks.set(id, updated);
  return updated;
}

function remove(id) {
  return bookmarks.delete(id);
}

function clear() {
  bookmarks.clear();
}

module.exports = { list, getById, create, update, remove, clear };
