// INTENTIONALLY SLOW — this is the starter for task 09 (performance fix)
// The bug: N+1 query problem + missing indexes

import express from 'express';

const app = express();
app.use(express.json());

// Simulated database with N+1 problem
interface Order {
  id: string;
  userId: string;
  total: number;
  createdAt: string;
}

interface OrderItem {
  id: string;
  orderId: string;
  productName: string;
  quantity: number;
  price: number;
}

// Simulated data
const orders: Order[] = Array.from({ length: 1000 }, (_, i) => ({
  id: `order-${i}`,
  userId: `user-${i % 50}`,
  total: Math.random() * 500,
  createdAt: new Date(Date.now() - Math.random() * 90 * 24 * 60 * 60 * 1000).toISOString(),
}));

const orderItems: OrderItem[] = orders.flatMap(order =>
  Array.from({ length: Math.floor(Math.random() * 5) + 1 }, (_, j) => ({
    id: `item-${order.id}-${j}`,
    orderId: order.id,
    productName: `Product ${j}`,
    quantity: Math.floor(Math.random() * 10) + 1,
    price: Math.random() * 100,
  }))
);

// BUG: N+1 query — fetches items one-by-one for each order
// BUG: No pagination — returns ALL 1000 orders
// BUG: No index on orderItems.orderId (simulated via linear scan)
app.get('/orders', async (req, res) => {
  const result = [];

  for (const order of orders) {
    // Simulated N+1: linear scan for each order's items
    const items = orderItems.filter(item => item.orderId === order.id);
    result.push({
      ...order,
      items,
      itemCount: items.length,
    });
  }

  res.json(result);
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT);

export default app;
