import { PrismaClient } from "@prisma/client";
import createOrganizations from "./seeders/orgSeeder.js";
// import { createBranches } from "./seeders/branchSeeder";
// import { createUsers } from "./seeders/userSeeder";
// import { createInvoices } from "./seeders/invoiceSeeder";
// import { createInvoiceLines } from "./seeders/invoiceLineSeeder";
import countrySeeder from "./seeders/CountrySeeder.js";
import roleSeeder from "./seeders/RoleSeeder.js";

const prisma = new PrismaClient();

const run = async () => {
  // Seed currencies and countries
  const country = await countrySeeder(prisma);
  const role = await roleSeeder(prisma);
  const orgs = await createOrganizations(prisma, 20);
  // const branches = await createBranches(orgs)
  // const users = await createUsers(orgs, branches)
  // const invoices = await createInvoices(users, branches)
  // await createInvoiceLines(invoices)
};

run()
  .then(() => {
    console.log("Seeding completed.");
    process.exit(0);
  })
  .catch((e) => {
    console.error("Seeding failed:", e);
    process.exit(1);
  });
