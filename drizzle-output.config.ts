import 'dotenv/config';

import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  out: './drizzle-output',
  schema: './src/modules/database/output-schema.ts',
  dialect: 'sqlite',
  dbCredentials: {
    url: './data/database.sqlite',
  },
});
