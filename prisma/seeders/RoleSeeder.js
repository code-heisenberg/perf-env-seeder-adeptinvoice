export default async function roleSeeder(prisma, now) {
  const roles = [
    { id: "role-1", name: "ADMIN" },
    { id: "role-2", name: "MANAGER" },
    { id: "role-3", name: "VALIDATOR" },
    { id: "role-4", name: "APPROVER" },
  ];

  for (const role of roles) {
    await prisma.role.upsert({
      where: { name: role.name },
      update: { id: role.id },
      create: role,
    });
  }

  console.log("roles", roles);
  // Return seeded data for further use

  const screens = [
    { name: "Admin Dashboard", code: "AD" },
    { name: "Dashboard", code: "DB" },
    { name: "Profile Popover", code: "PP" },
    { name: "User Management", code: "UM" },
    { name: "User Access Control", code: "UAC" },
    { name: "Entity Management", code: "EM" },
    { name: "Settings", code: "SE" },
    { name: "Report", code: "RP" },
    { name: "Business Rule", code: "BR" },
    { name: "Invoice To Validate", code: "IV" },
    { name: "Invoice by Supplier", code: "IS" },
    { name: "Past Processed Invoice", code: "IP" },
    { name: "Outgoing Invoice", code: "IO" },
    { name: "Unprocessed Files", code: "UN" },
    { name: "Activity Log", code: "AL" },
    { name: "Archive Invoices", code: "AI" },
  ];

  for (const screen of screens) {
    await prisma.screens.upsert({
      where: { code: screen.code },
      update: {},
      create: {
        ...screen,
      },
    });
  }
  console.log("screens", screens);

  // Seed screen permissions
  const screenPermissions = [
    {
      id: 1,
      roleId: "role-1",
      screenCode: "AD",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 2,
      roleId: "role-1",
      screenCode: "PP",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 3,
      roleId: "role-1",
      screenCode: "UM",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 4,
      roleId: "role-1",
      screenCode: "UAC",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 5,
      roleId: "role-1",
      screenCode: "EM",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 6,
      roleId: "role-1",
      screenCode: "SE",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 7,
      roleId: "role-1",
      screenCode: "RP",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 8,
      roleId: "role-1",
      screenCode: "BR",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 8,
      roleId: "role-1",
      screenCode: "AL",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 9,
      roleId: "role-2",
      screenCode: "AD",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 10,
      roleId: "role-2",
      screenCode: "PP",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 11,
      roleId: "role-2",
      screenCode: "IV",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 12,
      roleId: "role-2",
      screenCode: "IS",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 13,
      roleId: "role-2",
      screenCode: "IP",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 14,
      roleId: "role-3",
      screenCode: "DB",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 15,
      roleId: "role-3",
      screenCode: "PP",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 16,
      roleId: "role-3",
      screenCode: "IV",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 17,
      roleId: "role-3",
      screenCode: "IS",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 18,
      roleId: "role-3",
      screenCode: "IP",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 19,
      roleId: "role-4",
      screenCode: "DB",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 20,
      roleId: "role-4",
      screenCode: "PP",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 21,
      roleId: "role-4",
      screenCode: "IV",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 22,
      roleId: "role-4",
      screenCode: "IS",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 23,
      roleId: "role-4",
      screenCode: "IP",
      permission: ["VW", "CR"],
      organizationId: `ORG_${Date.now()}`,
    },
    {
      id: 24,
      roleId: "role-2",
      screenCode: "AI",
      permission: ["VW"],
      organizationId: `ORG_${Date.now()}`,
    },

    {
      id: 25,
      roleId: "role-4",
      screenCode: "AI",
      permission: ["VW"],
      organizationId: `ORG_${Date.now()}`,
    },
  ];

  for (const perm of screenPermissions) {
    await prisma.screenPermissions.upsert({
      where: { id: perm.id },
      update: {},
      create: perm,
    });
  }

  console.log("screenPermissions", screenPermissions);

  // Return seeded data for further use

  return {
    roles,
    screens,
    screenPermissions,
  };
}
