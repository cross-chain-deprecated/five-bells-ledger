CREATE SEQUENCE L_SEQ_ACCOUNT_PK
  INCREMENT BY 1
  START WITH 1
  NOCYCLE
  CACHE 100
  ORDER;

CREATE SEQUENCE L_SEQ_ENTRIES_PK
  INCREMENT BY 1
  START WITH 1
  NOCYCLE
  CACHE 100
  ORDER;

CREATE SEQUENCE L_SEQ_FULFILLMENTS_PK
  INCREMENT BY 1
  START WITH 1
  NOCYCLE
  CACHE 100
  ORDER;

CREATE SEQUENCE L_SEQ_TRANSFERS_PK
  INCREMENT BY 1
  START WITH 1
  NOCYCLE
  CACHE 100
  ORDER;

CREATE SEQUENCE L_SEQ_TRANSFER_ADJUSTMENTS_PK
  INCREMENT BY 1
  START WITH 1
  NOCYCLE
  CACHE 100
  ORDER;

CREATE TABLE "L_ACCOUNTS"
(
  "ACCOUNT_ID" INTEGER NOT NULL,
  "NAME" VARCHAR2(255) NOT NULL,
  "BALANCE" NUMBER(32,16) DEFAULT 0 NOT NULL,
  "CONNECTOR" VARCHAR2(1024) NULL,
  "PASSWORD_HASH" VARCHAR2(1024) NULL,
  "PUBLIC_KEY" VARCHAR2(4000) NULL,
  "IS_ADMIN" SMALLINT DEFAULT 0 NOT NULL,
  "IS_DISABLED" SMALLINT DEFAULT 0 NOT NULL,
  "FINGERPRINT" VARCHAR2(255) NULL,
  "MINIMUM_ALLOWED_BALANCE" NUMBER(32,16) DEFAULT 0 NULL,
  "DB_CREATED_DTTM" TIMESTAMP DEFAULT sysdate NOT NULL,
  "DB_UPDATED_DTTM" TIMESTAMP DEFAULT sysdate NOT NULL,
  "DB_UPDATED_USER" VARCHAR2(40) DEFAULT USER NOT NULL,
  CONSTRAINT "MIN_BALANCE_CONSTRAINT" CHECK
    ("BALANCE" >= "MINIMUM_ALLOWED_BALANCE")
);

CREATE INDEX L_XPK_ACCOUNTS ON "L_ACCOUNTS"
  ("ACCOUNT_ID" ASC);
ALTER TABLE "L_ACCOUNTS" ADD CONSTRAINT L_PK_ACCOUNTS PRIMARY KEY
  ("ACCOUNT_ID");
CREATE UNIQUE INDEX L_XAK_ACCOUNTS ON "L_ACCOUNTS"
  ("NAME" ASC);
ALTER TABLE "L_ACCOUNTS" ADD CONSTRAINT L_XAK_ACCOUNTS UNIQUE
  ("NAME");
CREATE INDEX L_XIE_FINGERPRINTS ON "L_ACCOUNTS"
  ("FINGERPRINT" ASC);


CREATE TABLE "L_LU_REJECTION_REASON" (
  "REJECTION_REASON_ID" INTEGER NOT NULL,
  "NAME" VARCHAR2(10) NOT NULL,
  "DESCRIPTION" VARCHAR2(255) NULL,
  "DB_CREATED_DTTM" TIMESTAMP DEFAULT sysdate NOT NULL,
  "DB_UPDATED_DTTM" TIMESTAMP DEFAULT sysdate NOT NULL,
  "DB_UPDATED_USER" VARCHAR2(40) DEFAULT USER NOT NULL
);

CREATE INDEX "L_XPK_LU_TRANSFERS_REJECTION_R" ON "L_LU_REJECTION_REASON"
  ("REJECTION_REASON_ID" ASC);
ALTER TABLE "L_LU_REJECTION_REASON" ADD CONSTRAINT
  "L_PK_LU_TRANSFERS_REJECTION_RE"
  PRIMARY KEY ("REJECTION_REASON_ID");
CREATE INDEX "L_XAK_LU_TRANSFERS_REJECTION_R" ON "L_LU_REJECTION_REASON"
  ("NAME" ASC);
ALTER TABLE "L_LU_REJECTION_REASON" ADD CONSTRAINT
  "L_AK_LU_TRANSFERS_REJECTION_RE" UNIQUE
  ("NAME");


CREATE TABLE "L_LU_TRANSFER_STATUS" (
  "STATUS_ID" INTEGER NOT NULL,
  "NAME" VARCHAR2(20) NOT NULL,
  "DESCRIPTION" VARCHAR2(255) NULL,
  "DB_CREATED_DTTM" TIMESTAMP DEFAULT sysdate NOT NULL,
  "DB_UPDATED_DTTM" TIMESTAMP DEFAULT sysdate NOT NULL,
  "DB_UPDATED_USER" VARCHAR2(40) DEFAULT USER NOT NULL
);

CREATE INDEX "L_XPK_LU_TRANSFER_STATUS" ON "L_LU_TRANSFER_STATUS"
  ("STATUS_ID" ASC);
ALTER TABLE "L_LU_TRANSFER_STATUS" ADD CONSTRAINT "L_PK_LU_TRANSFERS_STATUS"
  PRIMARY KEY ("STATUS_ID");
CREATE INDEX "L_XAK_LU_TRANSFER_STATUS" ON "L_LU_TRANSFER_STATUS"
  ("NAME" ASC);
ALTER TABLE "L_LU_TRANSFER_STATUS" ADD CONSTRAINT "L_AK_LU_TRANSFER_STATUS"
  UNIQUE ("NAME");


CREATE TABLE "L_TRANSFERS"
(
  "TRANSFER_ID" INTEGER NOT NULL,
  "TRANSFER_UUID" VARCHAR2(36) NOT NULL,
  "LEDGER" VARCHAR2(1024) NOT NULL,
  "STATUS_ID" INTEGER NOT NULL,
  "REJECTION_REASON_ID" INTEGER NULL,
  "ADDITIONAL_INFO" VARCHAR2(4000) NULL,
  "EXECUTION_CONDITION" VARCHAR2(4000) NULL,
  "CANCELLATION_CONDITION" VARCHAR2(4000) NULL,
  "EXPIRES_DTTM" TIMESTAMP NULL,
  "PROPOSED_DTTM" TIMESTAMP NULL,
  "PREPARED_DTTM" TIMESTAMP NULL,
  "EXECUTED_DTTM" TIMESTAMP NULL,
  "REJECTED_DTTM" TIMESTAMP NULL,
  "DB_CREATED_DTTM" TIMESTAMP DEFAULT sysdate NOT NULL,
  "DB_UPDATED_DTTM" TIMESTAMP DEFAULT sysdate NOT NULL,
  "DB_UPDATED_USER" VARCHAR2(40) DEFAULT USER NOT NULL
);

CREATE INDEX L_XPK_TRANSFERS ON "L_TRANSFERS"
  ("TRANSFER_ID" ASC);
ALTER TABLE "L_TRANSFERS" ADD CONSTRAINT L_PK_TRANSFERS PRIMARY KEY
  ("TRANSFER_ID");
/

CREATE INDEX L_XAK_TRANSFERS_EXECUTION_CONDITION ON "L_TRANSFERS"
  ("EXECUTION_CONDITION" ASC);
/

CREATE INDEX L_XAK_TRANSFERS ON "L_TRANSFERS"
  ("TRANSFER_UUID" ASC);
ALTER TABLE "L_TRANSFERS" ADD CONSTRAINT L_AK_TRANSFERS UNIQUE
  ("TRANSFER_UUID");
CREATE BITMAP INDEX L_XIF_TRANSFERS_STATUS ON "L_TRANSFERS"
  ("STATUS_ID" ASC);
CREATE BITMAP INDEX L_XIF_TRANSFERS_REASON ON "L_TRANSFERS"
  ("REJECTION_REASON_ID" ASC);
ALTER TABLE "L_TRANSFERS" ADD (CONSTRAINT FK_REJECTION_REASON_ID__TRANSF
  FOREIGN KEY ("REJECTION_REASON_ID") REFERENCES "L_LU_REJECTION_REASON"
  ("REJECTION_REASON_ID") ON DELETE SET NULL);
ALTER TABLE "L_TRANSFERS" ADD (CONSTRAINT FK_STATUS_ID__TRANSFERS
  FOREIGN KEY ("STATUS_ID") REFERENCES "L_LU_TRANSFER_STATUS"
  ("STATUS_ID") ON DELETE SET NULL);


CREATE TABLE "L_TRANSFER_ADJUSTMENTS"
(
  "TRANSFER_ADJUSTMENT_ID" INTEGER NOT NULL,
  "TRANSFER_ID" INTEGER NOT NULL,
  "ACCOUNT_ID" INTEGER NOT NULL,
  "DEBIT_CREDIT" VARCHAR2(10) NOT NULL,
  "AMOUNT" NUMBER(32,16) DEFAULT 0 NULL,
  "IS_AUTHORIZED" SMALLINT DEFAULT 0 NOT NULL,
  "MEMO" VARCHAR2(4000) NULL,
  "DB_CREATED_DTTM" TIMESTAMP DEFAULT sysdate NOT NULL,
  "DB_UPDATED_DTTM" TIMESTAMP DEFAULT sysdate NOT NULL,
  "DB_UPDATED_USER" VARCHAR2(40) DEFAULT USER NOT NULL
);

CREATE INDEX L_XPK_TRANSFER_ADJUSTMENTS ON "L_TRANSFER_ADJUSTMENTS"
  ("TRANSFER_ADJUSTMENT_ID" ASC);
ALTER TABLE "L_TRANSFER_ADJUSTMENTS" ADD CONSTRAINT PK_TRANSFER_ADJUSTMENTS
  PRIMARY KEY ("TRANSFER_ADJUSTMENT_ID");
CREATE UNIQUE INDEX L_XAK_TRANSFER_ADJUSTMENTS ON "L_TRANSFER_ADJUSTMENTS"
  ("TRANSFER_ID" ASC, "ACCOUNT_ID" ASC);
ALTER TABLE "L_TRANSFER_ADJUSTMENTS" ADD CONSTRAINT L_XAK_TRANSFER_ADJUSTMENTS
  UNIQUE ("TRANSFER_ID", "ACCOUNT_ID");
CREATE INDEX L_XIF_TRANSFER_ADJUSTMENTS_TRA ON "L_TRANSFER_ADJUSTMENTS"
  ("TRANSFER_ID" ASC);
CREATE INDEX L_XIF_TRANSFER_ADJUSTMENTS_ACC ON "L_TRANSFER_ADJUSTMENTS"
  ("ACCOUNT_ID" ASC);
CREATE INDEX L_XIE_TRANSFER_ADJUSTMENTS ON "L_TRANSFER_ADJUSTMENTS"
  ("IS_AUTHORIZED" ASC);
ALTER TABLE "L_TRANSFER_ADJUSTMENTS" ADD (CONSTRAINT
  FK_TRANSFER_ID__TRANSFER_DETAI FOREIGN KEY ("TRANSFER_ID")
  REFERENCES "L_TRANSFERS" ("TRANSFER_ID"));
ALTER TABLE "L_TRANSFER_ADJUSTMENTS" ADD (CONSTRAINT
  FK_ACCOUNTS_ID__TRANSFER_DETAI FOREIGN KEY ("ACCOUNT_ID")
  REFERENCES "L_ACCOUNTS" ("ACCOUNT_ID") ON DELETE SET NULL);


CREATE TABLE "L_ENTRIES"
(
  "ENTRY_ID" INTEGER NOT NULL,
  "TRANSFER_ID" INTEGER NOT NULL,
  "ACCOUNT_ID" INTEGER NOT NULL,
  "CREATED_DTTM" TIMESTAMP NOT NULL,
  "DB_CREATED_DTTM" TIMESTAMP DEFAULT sysdate NOT NULL,
  "DB_UPDATED_DTTM" TIMESTAMP DEFAULT sysdate NOT NULL,
  "DB_UPDATED_USER" VARCHAR2(40) DEFAULT USER NOT NULL
);

CREATE INDEX L_XPK_ENTRIES ON "L_ENTRIES"
  ("ENTRY_ID" ASC);
ALTER TABLE "L_ENTRIES" ADD CONSTRAINT L_PK_ENTRIES PRIMARY KEY
  ("ENTRY_ID");
CREATE INDEX L_XAK_ENTRIES ON "L_ENTRIES"
  ("TRANSFER_ID" ASC, "ACCOUNT_ID" ASC);
CREATE INDEX L_XIF_ENTRIES_ACCOUNT ON "L_ENTRIES"
  ("ACCOUNT_ID" ASC);
CREATE INDEX L_XIF_ENTRIES_TRANSFER ON "L_ENTRIES"
  ("TRANSFER_ID" ASC);
CREATE INDEX L_XIE_ENTRIES ON "L_ENTRIES"
  ("CREATED_DTTM" ASC);
ALTER TABLE "L_ENTRIES" ADD (CONSTRAINT FK_ACCOUNT_ID__ENTRIES FOREIGN KEY
  ("ACCOUNT_ID") REFERENCES "L_ACCOUNTS" ("ACCOUNT_ID") ON DELETE SET NULL);
ALTER TABLE "L_ENTRIES" ADD (CONSTRAINT FK_TRANSFER_ID__ENTRIES FOREIGN KEY
  ("TRANSFER_ID") REFERENCES "L_TRANSFERS" ("TRANSFER_ID") ON DELETE SET NULL);


CREATE TABLE "L_FULFILLMENTS"
(
  "FULFILLMENT_ID" INTEGER NOT NULL,
  "TRANSFER_ID" INTEGER NOT NULL,
  "CONDITION_FULFILLMENT" VARCHAR2(4000) NULL,
  "DB_CREATED_DTTM" TIMESTAMP DEFAULT sysdate NOT NULL,
  "DB_UPDATED_DTTM" TIMESTAMP DEFAULT sysdate NOT NULL,
  "DB_UPDATED_USER" VARCHAR2(40) DEFAULT USER NOT NULL
);

CREATE INDEX L_XPK_FULFILLMENTS ON "L_FULFILLMENTS"
  ("FULFILLMENT_ID" ASC);
ALTER TABLE "L_FULFILLMENTS" ADD CONSTRAINT L_PK_FULFILLMENTS PRIMARY KEY
  ("FULFILLMENT_ID");
CREATE INDEX L_XIF_FULFILLMENTS ON "L_FULFILLMENTS"
  ("TRANSFER_ID" ASC);
ALTER TABLE "L_FULFILLMENTS" ADD (CONSTRAINT FK_TRANSFER_ID__TRANSFERS
  FOREIGN KEY ("TRANSFER_ID") REFERENCES "L_TRANSFERS" ("TRANSFER_ID")
  ON DELETE SET NULL);


CREATE OR REPLACE TRIGGER L_TRG_ACCOUNTS_SEQ
  BEFORE INSERT
  ON "L_ACCOUNTS"
  FOR EACH ROW
  WHEN (new."ACCOUNT_ID" is null)
DECLARE
  v_id "L_ACCOUNTS"."ACCOUNT_ID"%TYPE;
BEGIN
  SELECT L_SEQ_ACCOUNT_PK.nextval INTO v_id FROM DUAL;
  :new."ACCOUNT_ID" := v_id;
END L_TRG_ACCOUNTS_SEQ;
/

CREATE OR REPLACE TRIGGER L_TRG_TRANSFER_ADJUSTMENTS_SEQ
  BEFORE INSERT
  ON "L_TRANSFER_ADJUSTMENTS"
  FOR EACH ROW
  WHEN (new."TRANSFER_ADJUSTMENT_ID" is null)
DECLARE
  v_id "L_TRANSFER_ADJUSTMENTS"."TRANSFER_ADJUSTMENT_ID"%TYPE;
BEGIN
  SELECT L_SEQ_TRANSFER_ADJUSTMENTS_PK.nextval INTO v_id FROM DUAL;
  :new."TRANSFER_ADJUSTMENT_ID" := v_id;
END L_TRG_TRANSFER_ADJUSTMENTS_SEQ;
/

CREATE OR REPLACE TRIGGER L_TRG_ENTRIES_SEQ
  BEFORE INSERT
  ON "L_ENTRIES"
  FOR EACH ROW
  WHEN (new."ENTRY_ID" is null)
DECLARE
  v_id "L_ENTRIES"."ENTRY_ID"%TYPE;
BEGIN
  SELECT L_SEQ_ENTRIES_PK.nextval INTO v_id FROM DUAL;
  :new."ENTRY_ID" := v_id;
END L_TRG_ENTRIES_SEQ;
/

CREATE OR REPLACE TRIGGER L_TRG_FULFILLMENTS_SEQ
  BEFORE INSERT
  ON "L_FULFILLMENTS"
  FOR EACH ROW
  WHEN (new."FULFILLMENT_ID" is null)
DECLARE
  v_id "L_FULFILLMENTS"."FULFILLMENT_ID"%TYPE;
BEGIN
  SELECT L_SEQ_FULFILLMENTS_PK.nextval INTO v_id FROM DUAL;
  :new."FULFILLMENT_ID" := v_id;
END L_TRG_FULFILLMENTS_SEQ;
/

CREATE OR REPLACE TRIGGER L_TRG_TRANSFERS_SEQ
  BEFORE INSERT
  ON "L_TRANSFERS"
  FOR EACH ROW
  WHEN (new."TRANSFER_ID" is null)
DECLARE
  v_id "L_TRANSFERS"."TRANSFER_ID"%TYPE;
BEGIN
  SELECT L_SEQ_TRANSFERS_PK.nextval INTO v_id FROM DUAL;
  :new."TRANSFER_ID" := v_id;
END L_TRG_TRANSFERS_SEQ;
/


CREATE OR REPLACE TRIGGER L_TRG_ENTRIES_INS
BEFORE INSERT
   ON "L_ENTRIES"
   FOR EACH ROW
BEGIN
   :new."CREATED_DTTM" := sysdate;
END;
/

CREATE OR REPLACE TRIGGER L_TRG_ACCOUNTS_UPDATE
BEFORE UPDATE
   ON "L_ACCOUNTS"
   FOR EACH ROW
BEGIN
   :new."DB_UPDATED_DTTM" := SYSDATE;
   :new."DB_UPDATED_USER" := USER;
END;
/

CREATE OR REPLACE TRIGGER L_TRG_ACCOUNTS_INSERT
BEFORE INSERT
   ON "L_ACCOUNTS"
   FOR EACH ROW
BEGIN
   :new."DB_CREATED_DTTM" := sysdate;
END;
/

CREATE OR REPLACE TRIGGER L_TRG_TRANSFERS_UPDATE
BEFORE UPDATE
   ON "L_TRANSFERS"
   FOR EACH ROW
BEGIN
   :new."DB_UPDATED_DTTM" := SYSDATE;
   :new."DB_UPDATED_USER" := USER;
END;
/

CREATE OR REPLACE TRIGGER L_TRG_TRANSFERS_INSERT
BEFORE INSERT
   ON "L_TRANSFERS"
   FOR EACH ROW
BEGIN
   :new."DB_CREATED_DTTM" := sysdate;
END;
/

CREATE OR REPLACE TRIGGER L_TRG_ENTRIES_UPDATE
BEFORE UPDATE
   ON "L_ENTRIES"
   FOR EACH ROW
BEGIN
   :new."DB_UPDATED_DTTM" := SYSDATE;
   :new."DB_UPDATED_USER" := USER;
END;
/

CREATE OR REPLACE TRIGGER L_TRG_ENTRIES_INSERT
BEFORE INSERT
   ON "L_ENTRIES"
   FOR EACH ROW
BEGIN
   :new."DB_CREATED_DTTM" := sysdate;
END;
/

CREATE OR REPLACE TRIGGER L_TRG_FULFILLMENTS_UPDATE
BEFORE UPDATE
   ON "L_FULFILLMENTS"
   FOR EACH ROW
BEGIN
   :new."DB_UPDATED_DTTM" := SYSDATE;
   :new."DB_UPDATED_USER" := USER;
END;
/

CREATE OR REPLACE TRIGGER L_TRG_FULFILLMENTS_INSERT
BEFORE INSERT
   ON "L_FULFILLMENTS"
   FOR EACH ROW
BEGIN
   :new."DB_CREATED_DTTM" := sysdate;
END;
/

CREATE OR REPLACE TRIGGER L_TRG_TRANSFER_ADJUSTMENTS_UPD
BEFORE UPDATE
   ON "L_TRANSFER_ADJUSTMENTS"
   FOR EACH ROW
BEGIN
   :new."DB_UPDATED_DTTM" := SYSDATE;
   :new."DB_UPDATED_USER" := USER;
END;
/

CREATE OR REPLACE TRIGGER L_TRG_TRANSFER_ADJUSTMENTS_INS
BEFORE INSERT
   ON "L_TRANSFER_ADJUSTMENTS"
   FOR EACH ROW
BEGIN
   :new."DB_CREATED_DTTM" := sysdate;
END;
/


CREATE PUBLIC SYNONYM "L_ACCOUNTS"
   FOR "L_ACCOUNTS";

CREATE PUBLIC SYNONYM "L_ENTRIES"
   FOR "L_ENTRIES";

CREATE PUBLIC SYNONYM "L_FULFILLMENTS"
   FOR "L_FULFILLMENTS";

CREATE PUBLIC SYNONYM "L_LU_REJECTION_REASON"
   FOR "L_LU_REJECTION_REASON";

CREATE PUBLIC SYNONYM "L_LU_TRANSFER_STATUS"
   FOR "L_LU_TRANSFER_STATUS";

CREATE PUBLIC SYNONYM "L_NOTIFICATIONS"
   FOR "L_NOTIFICATIONS";

CREATE PUBLIC SYNONYM "L_SUBSCRIPTIONS"
   FOR "L_SUBSCRIPTIONS";

CREATE PUBLIC SYNONYM "L_TRANSFER_ADJUSTMENTS"
   FOR "L_TRANSFER_ADJUSTMENTS";

CREATE PUBLIC SYNONYM "L_TRANSFERS"
   FOR "L_TRANSFERS";

INSERT INTO "L_LU_REJECTION_REASON" ("REJECTION_REASON_ID", "NAME", "DESCRIPTION")
  VALUES (0, 'cancelled', 'The transfer was cancelled');
INSERT INTO "L_LU_REJECTION_REASON" ("REJECTION_REASON_ID", "NAME", "DESCRIPTION")
  VALUES (1, 'expired', 'The transfer expired automatically');
INSERT INTO "L_LU_TRANSFER_STATUS" ("STATUS_ID", "NAME") VALUES (0, 'proposed');
INSERT INTO "L_LU_TRANSFER_STATUS" ("STATUS_ID", "NAME") VALUES (1, 'prepared');
INSERT INTO "L_LU_TRANSFER_STATUS" ("STATUS_ID", "NAME") VALUES (2, 'executed');
INSERT INTO "L_LU_TRANSFER_STATUS" ("STATUS_ID", "NAME") VALUES (3, 'rejected');

exit
