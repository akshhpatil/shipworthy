const request = require('supertest');
const app = require('./index');

// Clear bookmarks between tests
const bookmarks = new Map();

describe('Bookmark API', () => {
  test('GET /api/bookmarks returns empty array', async () => {
    const res = await request(app).get('/api/bookmarks');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  test('POST /api/bookmarks creates a bookmark', async () => {
    const res = await request(app)
      .post('/api/bookmarks')
      .send({ title: 'Test', url: 'https://test.com', tags: ['dev'] });
    expect(res.status).toBe(201);
    expect(res.body.id).toBeDefined();
    expect(res.body.title).toBe('Test');
  });

  test('POST /api/bookmarks rejects missing fields', async () => {
    const res = await request(app)
      .post('/api/bookmarks')
      .send({ url: 'https://test.com' });
    expect(res.status).toBe(400);
  });

  test('GET /api/bookmarks/:id returns 404 for unknown', async () => {
    const res = await request(app).get('/api/bookmarks/nonexistent');
    expect(res.status).toBe(404);
  });

  test('PUT /api/bookmarks/:id returns 404 for unknown', async () => {
    const res = await request(app)
      .put('/api/bookmarks/nonexistent')
      .send({ title: 'Nope' });
    expect(res.status).toBe(404);
  });

  test('DELETE /api/bookmarks/:id returns 404 for unknown', async () => {
    const res = await request(app).delete('/api/bookmarks/nonexistent');
    expect(res.status).toBe(404);
  });

  test('GET /health returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});
