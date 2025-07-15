const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function clear() {
  await prisma.$executeRawUnsafe(`
    TRUNCATE TABLE 
      "user"."users",
      "user"."branch",
      "user"."organization"
    RESTART IDENTITY CASCADE;
  `);
  console.log('Tables truncated');
  await prisma.$disconnect();
}

clear();
