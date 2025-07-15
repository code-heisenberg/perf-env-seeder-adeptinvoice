// File: prisma/seeders/orgSeeder.ts
import { faker } from '@faker-js/faker';

export async function createOrganizations(prisma, count) {
  const orgs = [];
  for (let i = 0; i < count; i++) {
    const org = await prisma.organization.create({
      data: {
        id: faker.string.uuid(),
        name: `Org-${i + 1}`,
        domain: faker.internet.domainName(),
        email: faker.internet.email(),
        emailPassword: faker.internet.password(),
        accessToken: { token: faker.string.uuid() },
        isActive: true,
        enableMasking: true,
        createdAt: new Date(),
        updatedAt: new Date(),
        invoiceRetentionPeriod: 90
      },
    });
    orgs.push(org);
  }
  return orgs;
}