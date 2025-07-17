// File: prisma/seeders/orgSeeder.ts
import { faker } from "@faker-js/faker";

//Format of the organization data
/*
id               String             @id
  name             String             @unique
  domain           String?            @unique
  settings         Json?
  email            String?            @unique
  emailPassword    String?
  accessToken      Json?
  createdAt        DateTime           @default(now())
  isActive         Boolean
  enableMasking    Boolean            @default(true)
  updatedAt     DateTime       @default(now())
  invoiceRetentionPeriod Int?  @default(90) // in days
*/

export default async function createOrganizations(prisma, count) {
  const orgs = [];
  for (let i = 0; i < count; i++) {
    const org = await prisma.organization.create({
      data: {
        id: `ORG_${Date.now()}`,
        name: faker.company.name(),
        domain: faker.internet.domainName(),
        email: faker.internet.email(),
        emailPassword: faker.internet.password(
          16,
          false,
          /^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[A-Za-z]{2,3}$/
        ),
        accessToken: { token: faker.string.uuid() },
        isActive: true,
        enableMasking: true,
        invoiceRetentionPeriod: 90,
      },
    });
    orgs.push(org);
  }
  console.log(`${orgs.length} organizations created`);
  return orgs;
}
