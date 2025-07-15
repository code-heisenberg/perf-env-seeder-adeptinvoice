export const createBranches = async (orgs) => {
  const branches = []
  for (const org of orgs) {
    for (let i = 1; i <= 20; i++) {
      const branch = await prisma.branch.create({
        data: {
          name: `Branch-${org.id}-${i}`,
          organizationId: org.id,
        },
      })
      branches.push(branch)
    }
  }
  return branches
}