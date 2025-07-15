export const createInvoices = async (users, branches) => {
  const invoices = []
  const validators = users.filter(u => u.role === 'VALIDATOR')
  const startDate = new Date('2024-07-01')

  for (let month = 0; month < 12; month++) {
    for (let i = 0; i < 25000; i++) {
      const user = validators[Math.floor(Math.random() * validators.length)]
      const branch = branches.find(b => b.id === user.branchId)
      const invoice = await prisma.invoice.create({
        data: {
          createdById: user.id,
          branchId: branch?.id ?? null,
          status: 'PENDING',
          date: new Date(startDate.getFullYear(), startDate.getMonth() + month, Math.floor(Math.random() * 28) + 1),
        },
      })
      invoices.push(invoice)
    }
    console.log(`Seeded month ${month + 1} - total invoices: ${(month + 1) * 25000}`)
  }

  return invoices
}
