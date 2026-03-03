import { faker } from '@faker-js/faker';

/**
 * Test Data Factory
 * Usage: import and call factory functions to generate test data
 * Run with: /test-data generate --schema user --count 50
 *
 * Prerequisites: npm install -D @faker-js/faker
 */

// --- Factory Functions ---

export function createUser(overrides: Partial<User> = {}): User {
  return {
    id: faker.number.int({ min: 1, max: 99999 }),
    name: faker.person.fullName(),
    email: faker.internet.email(),
    phone: faker.phone.number(),
    avatar: faker.image.avatar(),
    role: faker.helpers.arrayElement(['admin', 'user', 'editor', 'viewer']),
    address: {
      street: faker.location.streetAddress(),
      city: faker.location.city(),
      state: faker.location.state(),
      zip: faker.location.zipCode(),
      country: faker.location.country(),
    },
    isActive: faker.datatype.boolean({ probability: 0.85 }),
    createdAt: faker.date.past({ years: 2 }).toISOString(),
    ...overrides,
  };
}

export function createProduct(overrides: Partial<Product> = {}): Product {
  return {
    id: faker.number.int({ min: 1, max: 99999 }),
    name: faker.commerce.productName(),
    description: faker.commerce.productDescription(),
    price: parseFloat(faker.commerce.price({ min: 1, max: 999 })),
    category: faker.commerce.department(),
    sku: faker.string.alphanumeric(8).toUpperCase(),
    stock: faker.number.int({ min: 0, max: 500 }),
    image: faker.image.urlPicsumPhotos({ width: 640, height: 480 }),
    rating: parseFloat(faker.number.float({ min: 1, max: 5, fractionDigits: 1 }).toFixed(1)),
    isAvailable: faker.datatype.boolean({ probability: 0.9 }),
    createdAt: faker.date.past({ years: 1 }).toISOString(),
    ...overrides,
  };
}

export function createOrder(overrides: Partial<Order> = {}): Order {
  const items = Array.from(
    { length: faker.number.int({ min: 1, max: 5 }) },
    () => ({
      productId: faker.number.int({ min: 1, max: 99999 }),
      productName: faker.commerce.productName(),
      quantity: faker.number.int({ min: 1, max: 10 }),
      price: parseFloat(faker.commerce.price({ min: 5, max: 200 })),
    })
  );
  const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);

  return {
    id: faker.number.int({ min: 1, max: 99999 }),
    userId: faker.number.int({ min: 1, max: 9999 }),
    items,
    total: parseFloat(total.toFixed(2)),
    status: faker.helpers.arrayElement(['pending', 'processing', 'shipped', 'delivered', 'cancelled']),
    shippingAddress: {
      street: faker.location.streetAddress(),
      city: faker.location.city(),
      state: faker.location.state(),
      zip: faker.location.zipCode(),
      country: faker.location.country(),
    },
    createdAt: faker.date.recent({ days: 30 }).toISOString(),
    ...overrides,
  };
}

export function createPost(overrides: Partial<Post> = {}): Post {
  return {
    id: faker.number.int({ min: 1, max: 99999 }),
    title: faker.lorem.sentence({ min: 3, max: 10 }),
    body: faker.lorem.paragraphs({ min: 2, max: 5 }),
    authorId: faker.number.int({ min: 1, max: 9999 }),
    authorName: faker.person.fullName(),
    tags: faker.helpers.arrayElements(
      ['javascript', 'typescript', 'react', 'node', 'testing', 'devops', 'mobile', 'api'],
      { min: 1, max: 4 }
    ),
    likes: faker.number.int({ min: 0, max: 1000 }),
    publishedAt: faker.date.past({ years: 1 }).toISOString(),
    ...overrides,
  };
}

// --- Types ---

interface User {
  id: number;
  name: string;
  email: string;
  phone: string;
  avatar: string;
  role: string;
  address: Address;
  isActive: boolean;
  createdAt: string;
}

interface Product {
  id: number;
  name: string;
  description: string;
  price: number;
  category: string;
  sku: string;
  stock: number;
  image: string;
  rating: number;
  isAvailable: boolean;
  createdAt: string;
}

interface Order {
  id: number;
  userId: number;
  items: OrderItem[];
  total: number;
  status: string;
  shippingAddress: Address;
  createdAt: string;
}

interface OrderItem {
  productId: number;
  productName: string;
  quantity: number;
  price: number;
}

interface Post {
  id: number;
  title: string;
  body: string;
  authorId: number;
  authorName: string;
  tags: string[];
  likes: number;
  publishedAt: string;
}

interface Address {
  street: string;
  city: string;
  state: string;
  zip: string;
  country: string;
}

// --- Batch Generation ---

export function generateBatch<T>(factory: (overrides?: any) => T, count: number): T[] {
  return Array.from({ length: count }, () => factory());
}

// --- CLI Entry Point ---
// Run directly: node test-data-factory.ts --schema user --count 50
if (require.main === module) {
  const args = process.argv.slice(2);
  const schemaIdx = args.indexOf('--schema');
  const countIdx = args.indexOf('--count');
  const schema = schemaIdx !== -1 ? args[schemaIdx + 1] : 'user';
  const count = countIdx !== -1 ? parseInt(args[countIdx + 1]) : 10;

  const factories: Record<string, Function> = {
    user: createUser,
    product: createProduct,
    order: createOrder,
    post: createPost,
  };

  const factory = factories[schema];
  if (!factory) {
    console.error(`Unknown schema: ${schema}. Available: ${Object.keys(factories).join(', ')}`);
    process.exit(1);
  }

  const data = generateBatch(factory as any, count);
  console.log(JSON.stringify(data, null, 2));
}
