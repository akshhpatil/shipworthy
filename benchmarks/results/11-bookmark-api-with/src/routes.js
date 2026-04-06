const { Router } = require('express');
const bookmarks = require('./bookmarks');
const logger = require('./logger');

const router = Router();

router.get('/bookmarks', (req, res) => {
  const items = bookmarks.list();
  logger.info({ count: items.length }, 'listing bookmarks');
  res.json(items);
});

router.get('/bookmarks/:id', (req, res) => {
  const item = bookmarks.getById(req.params.id);
  if (!item) {
    return res.status(404).json({ error: 'Bookmark not found' });
  }
  res.json(item);
});

router.post('/bookmarks', (req, res) => {
  try {
    const bookmark = bookmarks.create(req.body);
    logger.info({ id: bookmark.id }, 'bookmark created');
    res.status(201).json(bookmark);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.put('/bookmarks/:id', (req, res) => {
  const updated = bookmarks.update(req.params.id, req.body);
  if (!updated) {
    return res.status(404).json({ error: 'Bookmark not found' });
  }
  logger.info({ id: updated.id }, 'bookmark updated');
  res.json(updated);
});

router.delete('/bookmarks/:id', (req, res) => {
  const deleted = bookmarks.remove(req.params.id);
  if (!deleted) {
    return res.status(404).json({ error: 'Bookmark not found' });
  }
  logger.info({ id: req.params.id }, 'bookmark deleted');
  res.status(204).send();
});

module.exports = router;
