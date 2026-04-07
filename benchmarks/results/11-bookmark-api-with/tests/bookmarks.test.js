const request = require('supertest');
const app = require('../src/app');
const bookmarks = require('../src/bookmarks');

beforeEach(() => {
  bookmarks.clear();
});

describe('GET /api/bookmarks', () => {
  test('returns empty array initially', async () => {
    const res = await request(app).get('/api/bookmarks');
    expect(res.status).toBe(200);
    expect(res.body).toEqual([]);
  });

  test('returns all bookmarks', async () => {
    bookmarks.create({ title: 'Example', url: 'https://example.com' });
    const res = await request(app).get('/api/bookmarks');
    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(1);
    expect(res.body[0].title).toBe('Example');
  });
});

describe('POST /api/bookmarks', () => {
  test('creates a bookmark', async () => {
    const res = await request(app)
      .post('/api/bookmarks')
      .send({ title: 'Test', url: 'https://test.com', tags: ['dev'] });
    expect(res.status).toBe(201);
    expect(res.body.id).toBeDefined();
    expect(res.body.title).toBe('Test');
    expect(res.body.tags).toEqual(['dev']);
  });

  test('rejects missing title', async () => {
    const res = await request(app)
      .post('/api/bookmarks')
      .send({ url: 'https://test.com' });
    expect(res.status).toBe(400);
    expect(res.body.error).toMatch(/title/);
  });

  test('rejects missing url', async () => {
    const res = await request(app)
      .post('/api/bookmarks')
      .send({ title: 'No URL' });
    expect(res.status).toBe(400);
    expect(res.body.error).toMatch(/url/);
  });
});

describe('GET /api/bookmarks/:id', () => {
  test('returns a specific bookmark', async () => {
    const created = bookmarks.create({ title: 'Find me', url: 'https://find.me' });
    const res = await request(app).get(`/api/bookmarks/${created.id}`);
    expect(res.status).toBe(200);
    expect(res.body.title).toBe('Find me');
  });

  test('returns 404 for unknown id', async () => {
    const res = await request(app).get('/api/bookmarks/nonexistent');
    expect(res.status).toBe(404);
  });
});

describe('PUT /api/bookmarks/:id', () => {
  test('updates a bookmark', async () => {
    const created = bookmarks.create({ title: 'Old', url: 'https://old.com' });
    const res = await request(app)
      .put(`/api/bookmarks/${created.id}`)
      .send({ title: 'New' });
    expect(res.status).toBe(200);
    expect(res.body.title).toBe('New');
    expect(res.body.url).toBe('https://old.com');
  });

  test('returns 404 for unknown id', async () => {
    const res = await request(app)
      .put('/api/bookmarks/nonexistent')
      .send({ title: 'Nope' });
    expect(res.status).toBe(404);
  });
});

describe('DELETE /api/bookmarks/:id', () => {
  test('deletes a bookmark', async () => {
    const created = bookmarks.create({ title: 'Delete me', url: 'https://bye.com' });
    const res = await request(app).delete(`/api/bookmarks/${created.id}`);
    expect(res.status).toBe(204);
    expect(bookmarks.getById(created.id)).toBeNull();
  });

  test('returns 404 for unknown id', async () => {
    const res = await request(app).delete('/api/bookmarks/nonexistent');
    expect(res.status).toBe(404);
  });
});

describe('GET /health', () => {
  test('returns ok status', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});
