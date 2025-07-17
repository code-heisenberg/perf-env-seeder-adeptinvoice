export default async function countrySeeder(prisma, now) {
  // 1. Create (or upsert) Currencies
  const currencies = [
    { id: "currency-inr", code: "INR", name: "Indian Rupee", symbol: "₹" },
    { id: "currency-eur", code: "EUR", name: "Euro", symbol: "€" },
    { id: "currency-usd", code: "USD", name: "US Dollar", symbol: "$" },
  ];

  for (const currency of currencies) {
    await prisma.currency.upsert({
      where: { code: currency.code },
      update: {},
      create: currency,
    });
  }

  // 2. Create (or upsert) Countries
  const countries = [
    {
      id: "1",
      code: "NL",
      name: "Netherlands",
      currencyCode: "EUR",
      countryCode: "+31",
    },
    {
      id: "2",
      code: "BE",
      name: "Belgium",
      currencyCode: "EUR",
      countryCode: "+32",
    },
  ];

  for (const country of countries) {
    await prisma.country.upsert({
      where: { id: country.id },
      update: {},
      create: country,
    });
  }

  // 3. Seed Tax Percentages
  const taxes = [
    {
      id: "1",
      name: "Standard VAT",
      rate: "0.00",
      description: "VAT 0%",
      countryId: "1", // Netherlands
    },
    {
      id: "2",
      name: "Standard VAT",
      rate: "9.00",
      description: "VAT 9%",
      countryId: "1",
    },
    {
      id: "3",
      name: "Standard VAT",
      rate: "21.00",
      description: "VAT 21%",
      countryId: "1",
    },
    {
      id: "4",
      name: "Standard VAT",
      rate: "0.00",
      description: "VAT 0%",
      countryId: "2", // Belgium
    },
    {
      id: "5",
      name: "Standard VAT",
      rate: "6.00",
      description: "VAT 6%",
      countryId: "2", // Belgium
    },
    {
      id: "6",
      name: "Standard VAT",
      rate: "12.00",
      description: "VAT 12%",
      countryId: "2", // Belgium
    },
    {
      id: "7",
      name: "Standard VAT",
      rate: "21.00",
      description: "VAT 21%",
      countryId: "2", // Belgium
    },
  ];
  for (const tax of taxes) {
    await prisma.tax.upsert({
      where: { id: tax.id },
      update: {},
      create: tax,
    });
  }

  const languages = [
    { id: "lang-en", code: "en", name: "English" },
    { id: "lang-fr", code: "fr", name: "French" },
    { id: "lang-nl", code: "nl", name: "Dutch" },
  ];

  for (const language of languages) {
    await prisma.language.upsert({
      where: { id: language.id },
      update: {},
      create: language,
    });
  }
  console.log("Seeded currencies, countries, taxes, and languages");
  // Return seeded data for further use
  console.log("Currencies:", currencies);
  console.log("Countries:", countries);
  console.log("Taxes:", taxes);
  console.log("Languages:", languages);

  return {
    currencies,
    countries,
    taxes,
    languages,
  };
}
