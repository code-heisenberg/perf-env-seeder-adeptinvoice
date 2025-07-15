# AdeptInvoice Seeder

This folder contains seeder scripts for the AdeptInvoice application, designed to populate PostgreSQL via Prisma using realistic dummy data with Faker.

---

## 📁 Structure

```
/prisma
├── schema.prisma                # Prisma DB schema
├── seed.js                      # Entry script for seeding
├── /seeders
│   ├── orgSeeder.js             # Seeds 5 organizations
│   ├── branchSeeder.js          # Seeds 20 branches per org (100 total)
│   └── userSeeder.js            # Seeds org and branch level users
    └── invoiceSeeder.js         # Seeds 12 months of invoices
    └── invoiceLineSeeder.js     # Seeds 3 lines per invoice
└──utils
    └── truncate.js              # Wipes and resets test data
```

---

## 📦 Requirements

Install dependencies:

```bash
npm install @prisma/client prisma @faker-js/faker
```

Make sure `.env` is present with:

```
DATABASE_URL="postgresql://username:password@host:port/dbname"
```

---

## 🚀 Run Seeder

```bash
npx prisma db seed
```

Prisma will execute `seed.js` which loads the following in order:

1. `createOrganizations()`
2. `createBranches()`
3. `createUsers()`
4. `createInvoices()`
5. `createInvoiceLines()`

You can re-run the seeder safely thanks to `upsert()` usage (no duplicates).

---

## 🔁 Optional Cleanup

Use a script like `truncate.js` to wipe and reset test data:

```bash
node prisma/truncate.js
```

---

## 🔄 Seeder Safety

- All user creation uses `upsert` (based on email)
- If you modify a seeder, just re-run `npx prisma db seed`
- Prisma will generate new entries only if they don’t already exist

---

## 🧩 Next Steps

- Add `invoiceSeeder.js` and `invoiceLineSeeder.js`
- Add `truncate.js` if you want full wipe support
- Use CI/CD step for test DB auto-setup (optional)

---

👨‍💻 Maintained by the AdeptInvoice Engineering Team