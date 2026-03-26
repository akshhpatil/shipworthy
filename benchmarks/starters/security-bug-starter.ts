// INTENTIONALLY VULNERABLE — this is the starter for task 04 (fix security bug)
// The bug: GET /users/:id returns any user's data without authorization checks

import express from 'express';

const app = express();
app.use(express.json());

// Simulated database
const users = [
  { id: '1', name: 'Alice', email: 'alice@example.com', ssn: '123-45-6789', balance: 5000 },
  { id: '2', name: 'Bob', email: 'bob@example.com', ssn: '987-65-4321', balance: 3200 },
  { id: '3', name: 'Charlie', email: 'charlie@example.com', ssn: '456-78-9012', balance: 8100 },
];

// BUG: No authorization check — any authenticated user can see any other user's data
app.get('/users/:id', (req, res) => {
  const user = users.find(u => u.id === req.params.id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  // BUG: Returns sensitive fields (SSN, balance) to any requester
  res.json(user);
});

app.get('/users', (req, res) => {
  // BUG: Returns all users with all fields
  res.json(users);
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT);

export default app;
