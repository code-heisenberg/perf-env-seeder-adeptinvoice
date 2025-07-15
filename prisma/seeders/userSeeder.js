// File: prisma/seeders/userSeeder.js
const { faker } = require('@faker-js/faker');

async function createUsers(prisma, orgs, branches) {
  const users = [];

  for (const org of orgs) {
    for (const roleName of ['VALIDATOR', 'APPROVER']) {
      for (let i = 0; i < 2; i++) {
        const role = await prisma.role.findFirst({ where: { name: roleName } });
        if (!role) throw new Error(`Role ${roleName} not found`);

        const user = await prisma.user.create({
          data: {
            id: faker.string.uuid(),
            email: faker.internet.email(),
            password: faker.internet.password(),
            firstName: faker.person.firstName(),
            lastName: faker.person.lastName(),
            status: 'ACTIVE',
            organizationId: org.id,
            roleId: role.id,
            createdAt: new Date(),
            updatedAt: new Date(),
          },
        });
        users.push(user);
      }
    }
  }

  for (const branch of branches) {
    for (const roleName of ['VALIDATOR', 'APPROVER', 'MANAGER']) {
      const role = await prisma.role.findFirst({ where: { name: roleName } });
      if (!role) throw new Error(`Role ${roleName} not found`);

      const user = await prisma.user.create({
        data: {
          id: faker.string.uuid(),
          email: faker.internet.email(),
          password: faker.internet.password(),
          firstName: faker.person.firstName(),
          lastName: faker.person.lastName(),
          status: 'ACTIVE',
          organizationId: branch.organizationId,
          roleId: role.id,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      });
      users.push(user);
    }
  }

  return users;
}
module.exports = { createUsers };