import { Client } from "pg";
import ExcelJS from "exceljs";

function formatDateTime(date) {
  const d = new Date(date);
  return d.toISOString().replace("T", " ").slice(0, 23);
}

function formatTime(ms) {
  if (!ms || isNaN(ms)) return "N/A";
  const seconds = Math.floor(ms / 1000);
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const sec = seconds % 60;
  const msLeft = ms % 1000;
  return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}:${String(sec).padStart(2, "0")}.${String(msLeft).padStart(3, "0")}`;
}

const client = new Client({
  connectionString: "postgresql://postgres:pguser@167.235.49.72:5432/AdeptInvoice-perf?schema=invoice",
});

const workbook = new ExcelJS.Workbook();
const sheet = workbook.addWorksheet("Invoice Extraction Analysis");

sheet.columns = [
  { header: "Invoice ID", key: "id", width: 35 },
  { header: "Inbox Time", key: "inboxTime", width: 30 },
  { header: "Invoice Created Time", key: "createdTime", width: 30 },
  { header: "Regex Extraction Time", key: "regexTime", width: 25 },
  { header: "Template Extraction Time", key: "templateTime", width: 30 },
  { header: "AI Extraction Time", key: "aiTime", width: 25 },
  { header: "Received → Final Status Time", key: "statusDuration", width: 30 },
  { header: "Total Extraction Time", key: "totalExtractionTime", width: 30 },
];

async function analyzeInvoices() {
  await client.connect();

  const invoices = await client.query(`
    SELECT id, "inboxDate", "createdAt"
    FROM invoice."invoices"
    ORDER BY "createdAt" DESC
    LIMIT 100
  `);

  for (const invoice of invoices.rows) {
    const { id, inboxDate, createdAt } = invoice;
    const inboxTime = new Date(inboxDate);
    const createdTime = new Date(createdAt);

    // Extraction times by method
    const extractRes = await client.query(`
      SELECT "extractionMethod", "createdAt", "updatedAt"
      FROM invoice."invoice_extraction_result"
      WHERE "invoiceId" = $1
    `, [id]);

    let regexTime = "N/A";
    let templateTime = "N/A";
    let aiTime = "N/A";

    let minStart = null;
    let maxEnd = null;

    for (const res of extractRes.rows) {
      const start = new Date(res.createdAt);
      const end = new Date(res.updatedAt);
      const diff = end - start;

      if (!minStart || start < minStart) minStart = start;
      if (!maxEnd || end > maxEnd) maxEnd = end;

      switch (res.extractionMethod) {
        case "REGEX":
          regexTime = formatTime(diff);
          break;
        case "TEMPLATE":
          templateTime = formatTime(diff);
          break;
        case "AI":
          aiTime = formatTime(diff);
          break;
      }
    }

    // RECEIVED → PENDING or UNPROCESSED
    const statusHist = await client.query(`
      SELECT status, "createdAt"
      FROM invoice."invoice_status_history"
      WHERE "invoiceId" = $1
      ORDER BY "createdAt" ASC
    `, [id]);

    const received = statusHist.rows.find(r => r.status === "RECEIVED");
    const final = statusHist.rows.reverse().find(r =>
      r.status === "PENDING" || r.status === "UNPROCESSED"
    );
    let statusDuration = "N/A";
    if (received && final) {
      statusDuration = formatTime(new Date(final.createdAt) - new Date(received.createdAt));
    }

    // Total extraction duration
    const totalExtractionTime =
      minStart && maxEnd ? formatTime(maxEnd - minStart) : "N/A";

    sheet.addRow({
      id,
      inboxTime: inboxTime ? formatDateTime(inboxTime) : "N/A",
      createdTime: createdTime ? formatDateTime(createdTime) : "N/A",
      regexTime,
      templateTime,
      aiTime,
      statusDuration,
      totalExtractionTime,
    });
  }

  await workbook.xlsx.writeFile("./jmeter_invoice_extraction_analysis.xlsx");
  console.log("✅ Report generated: jmeter_invoice_extraction_analysis.xlsx");
  await client.end();
}

analyzeInvoices().catch(console.error);
