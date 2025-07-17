-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "audit_log";

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "invoice";

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "metric";

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "notification";

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "payment";

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "user";

-- CreateEnum
CREATE TYPE "notification"."NotificationType" AS ENUM ('NEW_ENTITY_ASSIGNED', 'NEW_USER_ADDED', 'USER_ACCOUNT_ACTIVATED', 'NEW_INVOICE', 'INVOICE_DUE', 'TEMPLATE_TRAINING', 'NEW_SUPPLIER', 'NEW_CLIENT', 'PASSWORD_RESET', 'UNPROCESSED_FILES', 'ACCESS_UPDATED', 'NEW_CLIENT_INVOICE');

-- CreateEnum
CREATE TYPE "notification"."NotificationStatus" AS ENUM ('READ', 'UNREAD');

-- CreateEnum
CREATE TYPE "user"."UserStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'PENDING');

-- CreateEnum
CREATE TYPE "user"."UserTokenType" AS ENUM ('RESETPASSWORD', 'LOGIN');

-- CreateEnum
CREATE TYPE "invoice"."InvoiceStatus" AS ENUM ('RECEIVED', 'PENDING', 'IN_PROGRESS', 'UNDER_REVIEW', 'APPROVAL_IN_PROGRESS', 'APPROVED', 'ESCALATED', 'REJECTED', 'PAID', 'ARCHIVED', 'MARKED_INCORRECT', 'INCORRECT', 'INVOICE_TRAINING', 'INVOICE_TRAINING_IN_PROGRESS', 'INVOICE_TRAINING_COMPLETED', 'DUPLICATE_REJECTED', 'UNPROCESSED');

-- CreateEnum
CREATE TYPE "invoice"."FileTypes" AS ENUM ('PDF', 'IMAGE', 'XML', 'PNG', 'JPG');

-- CreateEnum
CREATE TYPE "invoice"."ProcessType" AS ENUM ('EMAIL_FETCH', 'FILE_STORAGE', 'FILE_PROCESSING', 'SAVE_TO_DB');

-- CreateEnum
CREATE TYPE "invoice"."ProcessStatus" AS ENUM ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED', 'RETRYING');

-- CreateEnum
CREATE TYPE "invoice"."InvoiceApprovalStatus" AS ENUM ('PENDING', 'VALIDATED', 'APPROVED', 'REJECTED', 'ESCALATED');

-- CreateEnum
CREATE TYPE "payment"."PaymentStatus" AS ENUM ('PENDING', 'PROCESSED', 'COMPLETED', 'FAILED');

-- CreateEnum
CREATE TYPE "payment"."TransactionStatus" AS ENUM ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "invoice"."InvoiceSource" AS ENUM ('EMAIL', 'API', 'PEPPOL_NETWORK');

-- CreateEnum
CREATE TYPE "invoice"."InvoiceKeywordType" AS ENUM ('Recurring', 'Prepaid', 'Intra_Community');

-- CreateEnum
CREATE TYPE "invoice"."TemplateType" AS ENUM ('Regex', 'Coordinate');

-- CreateEnum
CREATE TYPE "invoice"."ExtractionMethod" AS ENUM ('TEMPLATE', 'LLM');

-- CreateTable
CREATE TABLE "user"."organization" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "domain" TEXT,
    "settings" JSONB,
    "email" TEXT,
    "emailPassword" TEXT,
    "accessToken" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isActive" BOOLEAN NOT NULL,
    "enableMasking" BOOLEAN NOT NULL DEFAULT true,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "invoiceRetentionPeriod" INTEGER DEFAULT 90,

    CONSTRAINT "organization_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user"."branch" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "organizationId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "address" TEXT NOT NULL,
    "phoneNumber" TEXT,
    "email" TEXT,
    "emailPassword" TEXT,
    "accessToken" JSONB,
    "city" TEXT,
    "postalCode" TEXT,
    "countryId" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL,

    CONSTRAINT "branch_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user"."users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "status" "user"."UserStatus" NOT NULL,
    "organizationId" TEXT NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "roleId" TEXT NOT NULL,
    "forcePasswordReset" BOOLEAN NOT NULL DEFAULT false,
    "languageId" TEXT,
    "lastLoggedIn" TIMESTAMP(3),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user"."password_history" (
    "userId" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "password_history_pkey" PRIMARY KEY ("userId","createdAt")
);

-- CreateTable
CREATE TABLE "user"."branch_on_user" (
    "userId" TEXT NOT NULL,
    "branchId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "branch_on_user_pkey" PRIMARY KEY ("userId","branchId")
);

-- CreateTable
CREATE TABLE "user"."user_tokens" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "type" "user"."UserTokenType" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sessionId" TEXT,
    "deviceInfo" TEXT,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user"."departments" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "branchId" TEXT NOT NULL,
    "approvalLevel" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "departments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user"."user_department" (
    "userId" TEXT NOT NULL,
    "departmentId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_department_pkey" PRIMARY KEY ("userId","departmentId")
);

-- CreateTable
CREATE TABLE "user"."Client" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "phoneNumber" TEXT,
    "email" TEXT,
    "address" TEXT NOT NULL,
    "countryId" TEXT NOT NULL,
    "organizationId" TEXT NOT NULL,

    CONSTRAINT "Client_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user"."role" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "role_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user"."screens" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "screens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user"."ScreenPermissions" (
    "id" SERIAL NOT NULL,
    "screenCode" TEXT NOT NULL,
    "permission" TEXT[],
    "roleId" TEXT NOT NULL,
    "organizationId" TEXT NOT NULL,

    CONSTRAINT "ScreenPermissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user"."RoutePermission" (
    "id" SERIAL NOT NULL,
    "endpoint" TEXT NOT NULL,
    "permission" TEXT[],
    "roleId" TEXT NOT NULL,
    "organizationId" TEXT NOT NULL,

    CONSTRAINT "RoutePermission_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user"."language" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "language_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."invoices" (
    "id" TEXT NOT NULL,
    "invoiceNumber" TEXT,
    "supplierId" TEXT,
    "status" "invoice"."InvoiceStatus" NOT NULL,
    "totalAmount" DECIMAL(65,30),
    "taxPercentage" DECIMAL(65,30),
    "taxAmount" DECIMAL(65,30),
    "discountAmount" DECIMAL(65,30),
    "finalAmount" DECIMAL(65,30),
    "dueDate" TEXT,
    "invoiceDate" TEXT,
    "currencyId" TEXT,
    "source" "invoice"."InvoiceSource" NOT NULL,
    "uploadedBy" TEXT,
    "assignedUserId" TEXT,
    "workflowStep" INTEGER NOT NULL DEFAULT 1,
    "departmentId" TEXT,
    "isUrgent" BOOLEAN NOT NULL DEFAULT false,
    "isRecurring" BOOLEAN NOT NULL DEFAULT false,
    "isPrepaid" BOOLEAN NOT NULL DEFAULT false,
    "isIntraCommunity" BOOLEAN NOT NULL DEFAULT false,
    "validatorComments" TEXT,
    "approverComments" TEXT,
    "organizationId" TEXT NOT NULL,
    "branchId" TEXT,
    "fileName" TEXT,
    "filePath" TEXT,
    "sourceEmail" TEXT,
    "bankDetailId" TEXT,
    "flexiFields" JSONB,
    "mergedData" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "invoices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."invoice_item" (
    "id" TEXT NOT NULL,
    "lineItems" JSONB,
    "invoiceId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "invoice_item_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."invoice_template" (
    "id" TEXT NOT NULL,
    "templateName" TEXT NOT NULL,
    "keywords" TEXT[],
    "fingerprint" JSONB NOT NULL,
    "templateType" "invoice"."TemplateType" NOT NULL,
    "imagePath" TEXT NOT NULL,
    "drawnCoordinates" JSONB NOT NULL,
    "extractionCoordinates" JSONB NOT NULL,
    "organizationId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "invoice_template_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."invoice_extraction_result" (
    "id" TEXT NOT NULL,
    "invoiceId" TEXT NOT NULL,
    "templateId" TEXT,
    "modelId" TEXT,
    "rawOutput" JSONB,
    "parsedOutput" JSONB,
    "confidenceScore" DOUBLE PRECISION,
    "isSuccessful" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "extractionMethod" "invoice"."ExtractionMethod" NOT NULL,

    CONSTRAINT "invoice_extraction_result_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."field_definition" (
    "id" TEXT NOT NULL,
    "fieldName" TEXT NOT NULL,
    "dataType" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "isEnabled" BOOLEAN NOT NULL DEFAULT true,
    "isRequired" BOOLEAN NOT NULL DEFAULT false,
    "importanceScore" DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "field_definition_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."extraction_config" (
    "id" TEXT NOT NULL,
    "fieldId" TEXT NOT NULL,
    "templateId" TEXT NOT NULL,
    "extractionMethod" "invoice"."ExtractionMethod" NOT NULL,
    "confidenceThreshold" TEXT,
    "organisationId" TEXT NOT NULL,
    "autoSwitch" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "extraction_config_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."method_switch_log" (
    "id" SERIAL NOT NULL,
    "configId" TEXT NOT NULL,
    "fromMethod" "invoice"."ExtractionMethod" NOT NULL,
    "toMethod" "invoice"."ExtractionMethod" NOT NULL,
    "switchReason" TEXT,
    "switchedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "method_switch_log_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."field_result" (
    "id" TEXT NOT NULL,
    "invoiceId" TEXT NOT NULL,
    "fieldId" TEXT NOT NULL,
    "extractedValue" TEXT,
    "extractionMethod" "invoice"."ExtractionMethod" NOT NULL,
    "confidenceScore" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "field_result_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."field_correction" (
    "id" SERIAL NOT NULL,
    "invoiceId" TEXT NOT NULL,
    "historyId" TEXT,
    "fieldId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "originalValue" TEXT NOT NULL,
    "correctedValue" TEXT NOT NULL,
    "reason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "field_correction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."extraction_history" (
    "id" TEXT NOT NULL,
    "invoiceId" TEXT NOT NULL,
    "fieldId" TEXT NOT NULL,
    "method" "invoice"."ExtractionMethod" NOT NULL,
    "extractedValue" TEXT,
    "isSuccessful" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "extraction_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."field_escalation" (
    "id" TEXT NOT NULL,
    "invoiceId" TEXT NOT NULL,
    "fieldId" TEXT NOT NULL,
    "escalationReason" TEXT,
    "ticketId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "field_escalation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."llm_model_metadata" (
    "id" TEXT NOT NULL,
    "modelName" TEXT NOT NULL,
    "version" TEXT,
    "provider" TEXT NOT NULL,
    "configDetails" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "llm_model_metadata_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "metric"."field_metric" (
    "id" SERIAL NOT NULL,
    "fieldId" TEXT NOT NULL,
    "periodStart" TIMESTAMP(3) NOT NULL,
    "periodEnd" TIMESTAMP(3) NOT NULL,
    "templateFailures" INTEGER NOT NULL DEFAULT 0,
    "aiFailures" INTEGER NOT NULL DEFAULT 0,
    "userCorrections" INTEGER NOT NULL DEFAULT 0,
    "consecutiveFailures" INTEGER NOT NULL DEFAULT 0,
    "lastFailureAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "templateId" TEXT NOT NULL,

    CONSTRAINT "field_metric_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."InvoiceKeywords" (
    "id" SERIAL NOT NULL,
    "type" "invoice"."InvoiceKeywordType" NOT NULL,
    "keyword" TEXT NOT NULL,
    "language" TEXT NOT NULL,
    "frequency" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "invoiceId" TEXT,

    CONSTRAINT "InvoiceKeywords_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."invoice_metadata" (
    "id" TEXT NOT NULL,
    "queueId" TEXT,
    "fileUrl" TEXT NOT NULL,
    "rawData" TEXT,
    "finalExtractedData" JSONB,
    "fileType" "invoice"."FileTypes" NOT NULL,
    "errorMessage" TEXT,
    "retryCount" INTEGER NOT NULL DEFAULT 0,
    "lastAttemptAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "invoiceId" TEXT,
    "isTrained" BOOLEAN NOT NULL DEFAULT false,
    "isProcessed" BOOLEAN NOT NULL DEFAULT false,
    "isUnprocessed" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "invoice_metadata_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."invoice_queue" (
    "id" TEXT NOT NULL,
    "invoiceId" TEXT,
    "processType" "invoice"."ProcessType" NOT NULL,
    "status" "invoice"."ProcessStatus" NOT NULL,
    "retryCount" INTEGER NOT NULL DEFAULT 0,
    "errorMessage" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "invoice_queue_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."invoice_dept_approval" (
    "id" TEXT NOT NULL,
    "invoiceId" TEXT NOT NULL,
    "departmentId" TEXT NOT NULL,
    "approvalStatus" "invoice"."InvoiceApprovalStatus" NOT NULL,
    "approvedById" TEXT NOT NULL,
    "approvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "invoice_dept_approval_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."suppliers" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "contactEmail" TEXT,
    "phoneNumber" TEXT,
    "address" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "organizationId" TEXT NOT NULL,

    CONSTRAINT "suppliers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."bank_details" (
    "id" TEXT NOT NULL,
    "accountNumber" TEXT,
    "IFSCCode" TEXT,
    "swiftCode" TEXT,
    "currencyCode" TEXT NOT NULL,
    "IBANNumber" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "bank_details_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."country" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "currencyCode" TEXT NOT NULL,
    "countryCode" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "country_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."supplier_country" (
    "supplierId" TEXT NOT NULL,
    "countryId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "supplier_country_pkey" PRIMARY KEY ("supplierId","countryId")
);

-- CreateTable
CREATE TABLE "invoice"."supplier_bankdetails" (
    "supplierId" TEXT NOT NULL,
    "bankDetailsId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "supplier_bankdetails_pkey" PRIMARY KEY ("supplierId","bankDetailsId")
);

-- CreateTable
CREATE TABLE "invoice"."currency" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "symbol" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "locale" TEXT,

    CONSTRAINT "currency_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."branch_bank_details" (
    "id" TEXT NOT NULL,
    "branchId" TEXT NOT NULL,
    "bankDetailsId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "branch_bank_details_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."tax" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "rate" DECIMAL(65,30) NOT NULL,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "countryId" TEXT NOT NULL,

    CONSTRAINT "tax_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."client_invoice" (
    "id" TEXT NOT NULL,
    "invoiceNumber" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "paymentMethodId" TEXT NOT NULL,
    "billingAddressId" TEXT NOT NULL,
    "InvoiceDate" TIMESTAMP(3) NOT NULL,
    "dueDate" TIMESTAMP(3) NOT NULL,
    "projectName" TEXT,
    "totalAmount" DECIMAL(65,30) NOT NULL,
    "taxAmount" DECIMAL(65,30),
    "taxPercentage" DECIMAL(65,30),
    "finalAmount" DECIMAL(65,30) NOT NULL,
    "taxId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "client_invoice_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."client_invoice_line_item" (
    "id" TEXT NOT NULL,
    "clientInvoiceId" TEXT NOT NULL,
    "description" TEXT,
    "quantity" DOUBLE PRECISION,
    "unitPrice" DECIMAL(65,30),
    "totalPrice" DECIMAL(65,30) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "client_invoice_line_item_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."workflow" (
    "id" TEXT NOT NULL,
    "organizationId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdBy" TEXT NOT NULL,
    "updatedBy" TEXT NOT NULL,

    CONSTRAINT "workflow_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."workflowstep" (
    "id" TEXT NOT NULL,
    "workflowId" TEXT NOT NULL,
    "numValidators" INTEGER NOT NULL DEFAULT 1,
    "autoAssign" BOOLEAN NOT NULL DEFAULT false,
    "approvalLevels" INTEGER NOT NULL DEFAULT 1,
    "urgentThreshold" INTEGER NOT NULL DEFAULT 7,
    "departmentId" TEXT NOT NULL,
    "businessRuleId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "roleRequired" TEXT NOT NULL,

    CONSTRAINT "workflowstep_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."business_rule" (
    "id" TEXT NOT NULL,
    "organizationId" TEXT NOT NULL,
    "ruleName" TEXT NOT NULL,
    "field" TEXT,
    "condition" JSONB NOT NULL,
    "value" TEXT,
    "action" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "business_rule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."payment_method" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payment_method_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."supplier_payment_method" (
    "supplierId" TEXT NOT NULL,
    "paymentMethodId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "supplier_payment_method_pkey" PRIMARY KEY ("supplierId","paymentMethodId")
);

-- CreateTable
CREATE TABLE "payment"."supplier_payment_method" (
    "id" TEXT NOT NULL,
    "totalAmount" DOUBLE PRECISION NOT NULL,
    "currencyCode" TEXT NOT NULL,
    "status" "payment"."PaymentStatus" NOT NULL,
    "scheduledAt" TIMESTAMP(3),
    "processedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "supplier_payment_method_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment"."invoice_payment_batch" (
    "invoiceId" TEXT NOT NULL,
    "paymentBatchId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "invoice_payment_batch_pkey" PRIMARY KEY ("invoiceId","paymentBatchId")
);

-- CreateTable
CREATE TABLE "payment"."transaction" (
    "id" TEXT NOT NULL,
    "paymentBatchId" TEXT NOT NULL,
    "invoiceId" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "status" "payment"."TransactionStatus" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "remarks" TEXT,
    "paymentMethodId" TEXT,
    "currencyCode" TEXT NOT NULL,
    "supplierId" TEXT NOT NULL,

    CONSTRAINT "transaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_log"."AuditLog" (
    "id" SERIAL NOT NULL,
    "beforeData" JSONB,
    "eventData" JSONB,
    "metadata" JSONB,
    "impactData" JSONB,
    "serviceName" TEXT,
    "previousValues" JSONB,
    "newValues" JSONB,
    "entityType" TEXT,
    "entityId" TEXT,
    "action" TEXT,
    "createdBy" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "organizationId" TEXT,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice"."invoice_status_history" (
    "id" TEXT NOT NULL,
    "invoiceId" TEXT NOT NULL,
    "status" "invoice"."InvoiceStatus" NOT NULL,
    "previousStatus" "invoice"."InvoiceStatus",
    "userId" TEXT,
    "remarks" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "invoice_status_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification"."Notification" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "notification"."NotificationType" NOT NULL,
    "entityName" TEXT,
    "invoiceNumber" TEXT,
    "feature" TEXT,
    "meta" JSONB,
    "status" "notification"."NotificationStatus" NOT NULL DEFAULT 'UNREAD',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actionUrl" TEXT,
    "createdBy" TEXT,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user"."_BranchToWorkflow" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_BranchToWorkflow_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateTable
CREATE TABLE "user"."_DepartmentToOrganization" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_DepartmentToOrganization_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateTable
CREATE TABLE "user"."_DepartmentToUser" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_DepartmentToUser_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateTable
CREATE TABLE "invoice"."_InvoiceToPaymentBatch" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_InvoiceToPaymentBatch_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateTable
CREATE TABLE "invoice"."_BankDetailsToSupplier" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_BankDetailsToSupplier_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateIndex
CREATE UNIQUE INDEX "organization_name_key" ON "user"."organization"("name");

-- CreateIndex
CREATE UNIQUE INDEX "organization_domain_key" ON "user"."organization"("domain");

-- CreateIndex
CREATE UNIQUE INDEX "organization_email_key" ON "user"."organization"("email");

-- CreateIndex
CREATE UNIQUE INDEX "branch_code_key" ON "user"."branch"("code");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "user"."users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "user_tokens_token_key" ON "user"."user_tokens"("token");

-- CreateIndex
CREATE INDEX "user_tokens_userId_idx" ON "user"."user_tokens"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "role_name_key" ON "user"."role"("name");

-- CreateIndex
CREATE UNIQUE INDEX "screens_name_key" ON "user"."screens"("name");

-- CreateIndex
CREATE UNIQUE INDEX "screens_code_key" ON "user"."screens"("code");

-- CreateIndex
CREATE UNIQUE INDEX "ScreenPermissions_screenCode_roleId_organizationId_key" ON "user"."ScreenPermissions"("screenCode", "roleId", "organizationId");

-- CreateIndex
CREATE UNIQUE INDEX "RoutePermission_endpoint_roleId_organizationId_key" ON "user"."RoutePermission"("endpoint", "roleId", "organizationId");

-- CreateIndex
CREATE UNIQUE INDEX "language_code_key" ON "user"."language"("code");

-- CreateIndex
CREATE INDEX "invoices_supplierId_idx" ON "invoice"."invoices"("supplierId");

-- CreateIndex
CREATE INDEX "invoices_finalAmount_idx" ON "invoice"."invoices"("finalAmount");

-- CreateIndex
CREATE INDEX "invoices_invoiceDate_idx" ON "invoice"."invoices"("invoiceDate");

-- CreateIndex
CREATE UNIQUE INDEX "invoice_extraction_result_invoiceId_extractionMethod_key" ON "invoice"."invoice_extraction_result"("invoiceId", "extractionMethod");

-- CreateIndex
CREATE UNIQUE INDEX "field_metric_fieldId_templateId_key" ON "metric"."field_metric"("fieldId", "templateId");

-- CreateIndex
CREATE UNIQUE INDEX "InvoiceKeywords_keyword_language_key" ON "invoice"."InvoiceKeywords"("keyword", "language");

-- CreateIndex
CREATE UNIQUE INDEX "invoice_queue_invoiceId_key" ON "invoice"."invoice_queue"("invoiceId");

-- CreateIndex
CREATE UNIQUE INDEX "invoice_dept_approval_invoiceId_departmentId_key" ON "invoice"."invoice_dept_approval"("invoiceId", "departmentId");

-- CreateIndex
CREATE UNIQUE INDEX "bank_details_id_key" ON "invoice"."bank_details"("id");

-- CreateIndex
CREATE UNIQUE INDEX "country_code_key" ON "invoice"."country"("code");

-- CreateIndex
CREATE UNIQUE INDEX "currency_code_key" ON "invoice"."currency"("code");

-- CreateIndex
CREATE UNIQUE INDEX "branch_bank_details_branchId_bankDetailsId_key" ON "invoice"."branch_bank_details"("branchId", "bankDetailsId");

-- CreateIndex
CREATE UNIQUE INDEX "client_invoice_invoiceNumber_key" ON "invoice"."client_invoice"("invoiceNumber");

-- CreateIndex
CREATE INDEX "_BranchToWorkflow_B_index" ON "user"."_BranchToWorkflow"("B");

-- CreateIndex
CREATE INDEX "_DepartmentToOrganization_B_index" ON "user"."_DepartmentToOrganization"("B");

-- CreateIndex
CREATE INDEX "_DepartmentToUser_B_index" ON "user"."_DepartmentToUser"("B");

-- CreateIndex
CREATE INDEX "_InvoiceToPaymentBatch_B_index" ON "invoice"."_InvoiceToPaymentBatch"("B");

-- CreateIndex
CREATE INDEX "_BankDetailsToSupplier_B_index" ON "invoice"."_BankDetailsToSupplier"("B");

-- AddForeignKey
ALTER TABLE "user"."branch" ADD CONSTRAINT "branch_countryId_fkey" FOREIGN KEY ("countryId") REFERENCES "invoice"."country"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."branch" ADD CONSTRAINT "branch_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "user"."organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."users" ADD CONSTRAINT "users_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "user"."organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."users" ADD CONSTRAINT "users_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "user"."role"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."users" ADD CONSTRAINT "users_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "user"."language"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."password_history" ADD CONSTRAINT "password_history_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."branch_on_user" ADD CONSTRAINT "branch_on_user_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."branch_on_user" ADD CONSTRAINT "branch_on_user_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "user"."branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."user_tokens" ADD CONSTRAINT "user_tokens_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."departments" ADD CONSTRAINT "departments_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "user"."branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."user_department" ADD CONSTRAINT "user_department_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "user"."departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."user_department" ADD CONSTRAINT "user_department_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."Client" ADD CONSTRAINT "Client_countryId_fkey" FOREIGN KEY ("countryId") REFERENCES "invoice"."country"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."Client" ADD CONSTRAINT "Client_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "user"."organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoices" ADD CONSTRAINT "invoices_assignedUserId_fkey" FOREIGN KEY ("assignedUserId") REFERENCES "user"."users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoices" ADD CONSTRAINT "invoices_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "user"."branch"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoices" ADD CONSTRAINT "invoices_currencyId_fkey" FOREIGN KEY ("currencyId") REFERENCES "invoice"."currency"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoices" ADD CONSTRAINT "invoices_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "user"."departments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoices" ADD CONSTRAINT "invoices_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "user"."organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoices" ADD CONSTRAINT "invoices_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "invoice"."suppliers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoices" ADD CONSTRAINT "invoices_bankDetailId_fkey" FOREIGN KEY ("bankDetailId") REFERENCES "invoice"."bank_details"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoice_item" ADD CONSTRAINT "invoice_item_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "invoice"."invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoice_template" ADD CONSTRAINT "invoice_template_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "user"."organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoice_extraction_result" ADD CONSTRAINT "invoice_extraction_result_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "invoice"."invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoice_extraction_result" ADD CONSTRAINT "invoice_extraction_result_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "invoice"."invoice_template"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."extraction_config" ADD CONSTRAINT "extraction_config_fieldId_fkey" FOREIGN KEY ("fieldId") REFERENCES "invoice"."field_definition"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."extraction_config" ADD CONSTRAINT "extraction_config_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "invoice"."invoice_template"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."extraction_config" ADD CONSTRAINT "extraction_config_organisationId_fkey" FOREIGN KEY ("organisationId") REFERENCES "user"."organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."method_switch_log" ADD CONSTRAINT "method_switch_log_configId_fkey" FOREIGN KEY ("configId") REFERENCES "invoice"."extraction_config"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."field_result" ADD CONSTRAINT "field_result_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "invoice"."invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."field_result" ADD CONSTRAINT "field_result_fieldId_fkey" FOREIGN KEY ("fieldId") REFERENCES "invoice"."field_definition"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."field_correction" ADD CONSTRAINT "field_correction_fieldId_fkey" FOREIGN KEY ("fieldId") REFERENCES "invoice"."field_definition"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."field_correction" ADD CONSTRAINT "field_correction_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."field_correction" ADD CONSTRAINT "field_correction_historyId_fkey" FOREIGN KEY ("historyId") REFERENCES "invoice"."extraction_history"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."field_correction" ADD CONSTRAINT "field_correction_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "invoice"."invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."extraction_history" ADD CONSTRAINT "extraction_history_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "invoice"."invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."field_escalation" ADD CONSTRAINT "field_escalation_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "invoice"."invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."field_escalation" ADD CONSTRAINT "field_escalation_fieldId_fkey" FOREIGN KEY ("fieldId") REFERENCES "invoice"."field_definition"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "metric"."field_metric" ADD CONSTRAINT "field_metric_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "invoice"."invoice_template"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "metric"."field_metric" ADD CONSTRAINT "field_metric_fieldId_fkey" FOREIGN KEY ("fieldId") REFERENCES "invoice"."field_definition"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."InvoiceKeywords" ADD CONSTRAINT "InvoiceKeywords_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "invoice"."invoices"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoice_metadata" ADD CONSTRAINT "invoice_metadata_queueId_fkey" FOREIGN KEY ("queueId") REFERENCES "invoice"."invoice_queue"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoice_metadata" ADD CONSTRAINT "invoice_metadata_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "invoice"."invoices"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoice_queue" ADD CONSTRAINT "invoice_queue_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "invoice"."invoices"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoice_dept_approval" ADD CONSTRAINT "invoice_dept_approval_approvedById_fkey" FOREIGN KEY ("approvedById") REFERENCES "user"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoice_dept_approval" ADD CONSTRAINT "invoice_dept_approval_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "user"."departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoice_dept_approval" ADD CONSTRAINT "invoice_dept_approval_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "invoice"."invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."suppliers" ADD CONSTRAINT "suppliers_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "user"."organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."bank_details" ADD CONSTRAINT "bank_details_currencyCode_fkey" FOREIGN KEY ("currencyCode") REFERENCES "invoice"."currency"("code") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."country" ADD CONSTRAINT "country_currencyCode_fkey" FOREIGN KEY ("currencyCode") REFERENCES "invoice"."currency"("code") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."supplier_country" ADD CONSTRAINT "supplier_country_countryId_fkey" FOREIGN KEY ("countryId") REFERENCES "invoice"."country"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."supplier_country" ADD CONSTRAINT "supplier_country_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "invoice"."suppliers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."supplier_bankdetails" ADD CONSTRAINT "supplier_bankdetails_bankDetailsId_fkey" FOREIGN KEY ("bankDetailsId") REFERENCES "invoice"."bank_details"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."supplier_bankdetails" ADD CONSTRAINT "supplier_bankdetails_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "invoice"."suppliers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."branch_bank_details" ADD CONSTRAINT "branch_bank_details_bankDetailsId_fkey" FOREIGN KEY ("bankDetailsId") REFERENCES "invoice"."bank_details"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."branch_bank_details" ADD CONSTRAINT "branch_bank_details_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "user"."branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."tax" ADD CONSTRAINT "tax_countryId_fkey" FOREIGN KEY ("countryId") REFERENCES "invoice"."country"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."client_invoice" ADD CONSTRAINT "client_invoice_billingAddressId_fkey" FOREIGN KEY ("billingAddressId") REFERENCES "user"."branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."client_invoice" ADD CONSTRAINT "client_invoice_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "user"."Client"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."client_invoice" ADD CONSTRAINT "client_invoice_paymentMethodId_fkey" FOREIGN KEY ("paymentMethodId") REFERENCES "invoice"."branch_bank_details"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."client_invoice" ADD CONSTRAINT "client_invoice_taxId_fkey" FOREIGN KEY ("taxId") REFERENCES "invoice"."tax"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."client_invoice_line_item" ADD CONSTRAINT "client_invoice_line_item_clientInvoiceId_fkey" FOREIGN KEY ("clientInvoiceId") REFERENCES "invoice"."client_invoice"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."workflow" ADD CONSTRAINT "workflow_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "user"."organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."workflow" ADD CONSTRAINT "workflow_updatedBy_fkey" FOREIGN KEY ("updatedBy") REFERENCES "user"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."workflowstep" ADD CONSTRAINT "workflowstep_businessRuleId_fkey" FOREIGN KEY ("businessRuleId") REFERENCES "invoice"."business_rule"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."workflowstep" ADD CONSTRAINT "workflowstep_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "user"."departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."workflowstep" ADD CONSTRAINT "workflowstep_roleRequired_fkey" FOREIGN KEY ("roleRequired") REFERENCES "user"."role"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."workflowstep" ADD CONSTRAINT "workflowstep_workflowId_fkey" FOREIGN KEY ("workflowId") REFERENCES "invoice"."workflow"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."business_rule" ADD CONSTRAINT "business_rule_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "user"."organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."supplier_payment_method" ADD CONSTRAINT "supplier_payment_method_paymentMethodId_fkey" FOREIGN KEY ("paymentMethodId") REFERENCES "invoice"."payment_method"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."supplier_payment_method" ADD CONSTRAINT "supplier_payment_method_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "invoice"."suppliers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment"."supplier_payment_method" ADD CONSTRAINT "supplier_payment_method_currencyCode_fkey" FOREIGN KEY ("currencyCode") REFERENCES "invoice"."currency"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment"."invoice_payment_batch" ADD CONSTRAINT "invoice_payment_batch_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "invoice"."invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment"."invoice_payment_batch" ADD CONSTRAINT "invoice_payment_batch_paymentBatchId_fkey" FOREIGN KEY ("paymentBatchId") REFERENCES "payment"."supplier_payment_method"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment"."transaction" ADD CONSTRAINT "transaction_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "invoice"."invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment"."transaction" ADD CONSTRAINT "transaction_paymentBatchId_fkey" FOREIGN KEY ("paymentBatchId") REFERENCES "payment"."supplier_payment_method"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment"."transaction" ADD CONSTRAINT "transaction_currencyCode_fkey" FOREIGN KEY ("currencyCode") REFERENCES "invoice"."currency"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment"."transaction" ADD CONSTRAINT "transaction_paymentMethodId_fkey" FOREIGN KEY ("paymentMethodId") REFERENCES "invoice"."payment_method"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment"."transaction" ADD CONSTRAINT "transaction_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "invoice"."suppliers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."invoice_status_history" ADD CONSTRAINT "invoice_status_history_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "invoice"."invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification"."Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."_BranchToWorkflow" ADD CONSTRAINT "_BranchToWorkflow_A_fkey" FOREIGN KEY ("A") REFERENCES "user"."branch"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."_BranchToWorkflow" ADD CONSTRAINT "_BranchToWorkflow_B_fkey" FOREIGN KEY ("B") REFERENCES "invoice"."workflow"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."_DepartmentToOrganization" ADD CONSTRAINT "_DepartmentToOrganization_A_fkey" FOREIGN KEY ("A") REFERENCES "user"."departments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."_DepartmentToOrganization" ADD CONSTRAINT "_DepartmentToOrganization_B_fkey" FOREIGN KEY ("B") REFERENCES "user"."organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."_DepartmentToUser" ADD CONSTRAINT "_DepartmentToUser_A_fkey" FOREIGN KEY ("A") REFERENCES "user"."departments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user"."_DepartmentToUser" ADD CONSTRAINT "_DepartmentToUser_B_fkey" FOREIGN KEY ("B") REFERENCES "user"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."_InvoiceToPaymentBatch" ADD CONSTRAINT "_InvoiceToPaymentBatch_A_fkey" FOREIGN KEY ("A") REFERENCES "invoice"."invoices"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."_InvoiceToPaymentBatch" ADD CONSTRAINT "_InvoiceToPaymentBatch_B_fkey" FOREIGN KEY ("B") REFERENCES "payment"."supplier_payment_method"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."_BankDetailsToSupplier" ADD CONSTRAINT "_BankDetailsToSupplier_A_fkey" FOREIGN KEY ("A") REFERENCES "invoice"."bank_details"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice"."_BankDetailsToSupplier" ADD CONSTRAINT "_BankDetailsToSupplier_B_fkey" FOREIGN KEY ("B") REFERENCES "invoice"."suppliers"("id") ON DELETE CASCADE ON UPDATE CASCADE;
