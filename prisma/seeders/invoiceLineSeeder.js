export const createInvoiceLines = async (invoices) => {
  for (const invoice of invoices) {
    const lines = Array.from({ length: 3 }).map(() => ({
      invoiceId: invoice.id,
      itemName: faker.commerce.productName(),
      quantity: Math.floor(Math.random() * 10) + 1,
      amount: Number(faker.commerce.price({ min: 100, max: 500 })),
    }))

    await prisma.invoiceLine.createMany({ data: lines })
  }
}
