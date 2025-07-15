import { PrismaClient } from '@prisma/client';
import { createOrganizations } from './seeders/orgSeeder';
import { createBranches } from './seeders/branchSeeder';
import { createUsers } from './seeders/userSeeder';
import { createInvoices } from './seeders/invoiceSeeder';
import { createInvoiceLines } from './seeders/invoiceLineSeeder';

const prisma = new PrismaClient();

const run = async () => {
  const orgs = await createOrganizations()
  const branches = await createBranches(orgs)
  const users = await createUsers(orgs, branches)
  const invoices = await createInvoices(users, branches)
  await createInvoiceLines(invoices)
}

run().then(() => {
  console.log('Seeding completed.')
  process.exit(0)
}).catch((e) => {
  console.error("Seeding failed:", e)
  process.exit(1)
});
