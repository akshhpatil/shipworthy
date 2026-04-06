const express = require('express');
const crypto = require('crypto');

const app = express();
app.use(express.json());

const PORT = 3000;

// In-memory store
const bookmarks = new Map();

// List all bookmarks
app.get('/api/bookmarks', (req, res) => {
  console.log('GET /api/bookmarks');
  res.json(Array.from(bookmarks.values()));
});

// Get bookmark by ID
app.get('/api/bookmarks/:id', (req, res) => {
  const bookmark = bookmarks.get(req.params.id);
  if (!bookmark) {
    return res.status(404).json({ error: 'Not found' });
  }
  res.json(bookmark);
});

// Create bookmark
app.post('/api/bookmarks', (req, res) => {
  const { title, url, tags } = req.body;
  if (!title || !url) {
    return res.status(400).json({ error: 'title and url are required' });
  }
  const bookmark = {
    id: crypto.randomUUID(),
    title,
    url,
    tags: tags || [],
    createdAt: new Date().toISOString(),
  };
  bookmarks.set(bookmark.id, bookmark);
  console.log('Created bookmark:', bookmark.id);
  res.status(201).json(bookmark);
});

// Update bookmark
app.put('/api/bookmarks/:id', (req, res) => {
  const existing = bookmarks.get(req.params.id);
  if (!existing) {
    return res.status(404).json({ error: 'Not found' });
  }
  const updated = { ...existing, ...req.body, id: existing.id, createdAt: existing.createdAt };
  bookmarks.set(existing.id, updated);
  console.log('Updated bookmark:', existing.id);
  res.json(updated);
});

// Delete bookmark
app.delete('/api/bookmarks/:id', (req, res) => {
  if (!bookmarks.delete(req.params.id)) {
    return res.status(404).json({ error: 'Not found' });
  }
  console.log('Deleted bookmark:', req.params.id);
  res.status(204).send();
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
